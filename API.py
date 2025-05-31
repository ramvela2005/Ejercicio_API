from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS 
from datetime import datetime
from sqlalchemy.dialects.postgresql import ENUM


app = Flask(__name__)
CORS(app)  

incident_status_enum = ENUM('Pendiente', 'En proceso', 'Resuelto', name='incident_status', create_type=False)

# Configuración de PostgreSQL (nombre del contenedor db como host)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://apiuser:apipassword@db:5432/incidentes_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Tabla intermedia
incident_categories = db.Table('incident_categories',
    db.Column('incident_id', db.Integer, db.ForeignKey('incident.id'), primary_key=True),
    db.Column('category_id', db.Integer, db.ForeignKey('category.id'), primary_key=True)
)

# Modelo de categoría
class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)

    def to_dict(self):
        return {"id": self.id, "name": self.name}
    

# Modelo de incidente
class Incident(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reporter = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    status = db.Column(incident_status_enum, server_default='Pendiente', nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    categories = db.relationship('Category', secondary=incident_categories, backref='incidents')
    
    # to_dict sigue igual...


    def to_dict(self):
        return {
            "id": self.id,
            "reporter": self.reporter,
            "description": self.description,
            "status": self.status,
            "created_at": self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "categories": [c.to_dict() for c in self.categories]
        }
    
class IncidentWithCategories(db.Model):
    __tablename__ = 'incident_with_categories'
    __table_args__ = {'extend_existing': True}

    incident_id = db.Column(db.Integer, primary_key=True)
    reporter = db.Column(db.String, nullable=True)
    description = db.Column(db.Text, nullable=True)
    status = db.Column(db.String, nullable=True)
    created_at = db.Column(db.DateTime, nullable=True)
    category_names = db.Column(db.String, nullable=True)


@app.route('/')
def welcome():
    return jsonify({
        "message": "Bienvenido a la API de incidentes",
        "endpoints": {
            "POST /incidents": "Crear un nuevo incidente",
            "GET /incidents": "Obtener lista de incidentes",
            "GET /incidents/<id>": "Obtener un incidente específico",
            "PUT /incidents/<id>": "Actualizar estado del incidente",
            "DELETE /incidents/<id>": "Eliminar un incidente"
        }
    })

with app.app_context():
    db.create_all()

    # Categorías iniciales si no existen
    if Category.query.count() == 0:
        default_categories = ["Infraestructura", "Seguridad", "Tecnología", "Salud"]
        for name in default_categories:
            db.session.add(Category(name=name))
        db.session.commit()

# Crear un incidente
@app.route('/incidents', methods=['POST'])
def create_incident():
    data = request.get_json()
    reporter = data.get("reporter", "").strip()
    description = data.get("description", "").strip()
    category_ids = data.get("categories", [])

    if not reporter:
        return jsonify({"error": "El campo 'reporter' es obligatorio"}), 400
    if len(description) < 10:
        return jsonify({"error": "La descripción debe tener al menos 10 caracteres"}), 400

    # Validar categorías
    categories = Category.query.filter(Category.id.in_(category_ids)).all()

    incident = Incident(
        reporter=reporter,
        description=description,
        status=data.get("status", "Pendiente"),
        categories=categories
    )

    db.session.add(incident)
    db.session.commit()
    return jsonify(incident.to_dict()), 201


# Obtener todos los incidentes
@app.route('/incidents', methods=['GET'])
def get_incidents():
    incidents = Incident.query.all()
    return jsonify([i.to_dict() for i in incidents])

# Obtener un incidente específico
@app.route('/incidents/<int:incident_id>', methods=['GET'])
def get_incident(incident_id):
    incident = Incident.query.get(incident_id)
    if not incident:
        return jsonify({"error": "Incidente no encontrado"}), 404
    return jsonify(incident.to_dict())

# Eliminar un incidente
@app.route('/incidents/<int:incident_id>', methods=['DELETE'])
def delete_incident(incident_id):
    incident = Incident.query.get(incident_id)
    if not incident:
        return jsonify({"error": "Incidente no encontrado"}), 404

    db.session.delete(incident)
    db.session.commit()
    return jsonify({"message": "Incidente eliminado correctamente"}), 200


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3001, debug=True)

@app.route('/view/incidents', methods=['GET'])
def get_incidents_from_view():
    rows = IncidentWithCategories.query.all()
    result = []
    for row in rows:
        result.append({
            "id": row.incident_id,
            "reporter": row.reporter,
            "description": row.description,
            "status": row.status,
            "created_at": row.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "categories": row.category_names
        })
    return jsonify(result)

@app.route('/categories', methods=['GET'])
def get_categories():
    categories = Category.query.all()
    return jsonify([c.to_dict() for c in categories])

@app.route('/incidents/<int:incident_id>', methods=['PUT'])
def update_incident(incident_id):
    incident = Incident.query.get(incident_id)
    if not incident:
        return jsonify({"error": "Incidente no encontrado"}), 404

    data = request.get_json()

    # Actualizar estado si viene
    new_status = data.get("status")
    if new_status:
        new_status = new_status.capitalize()
        if new_status not in ["Pendiente", "En proceso", "Resuelto"]:
            return jsonify({"error": "Estado inválido. Debe ser Pendiente, En proceso o Resuelto"}), 400
        incident.status = new_status

    # Actualizar categorías si vienen
    category_ids = data.get("categories")
    if category_ids is not None:
        categories = Category.query.filter(Category.id.in_(category_ids)).all()
        incident.categories = categories

    db.session.commit()
    return jsonify(incident.to_dict())
