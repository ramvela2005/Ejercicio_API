from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)

# Configuración de PostgreSQL
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://apiuser:apipassword@localhost:5432/incidentes_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Modelo de incidente
class Incident(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reporter = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default="Pendiente")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "reporter": self.reporter,
            "description": self.description,
            "status": self.status,
            "created_at": self.created_at.strftime("%Y-%m-%d %H:%M:%S")
        }

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

# Crear un incidente
@app.route('/incidents', methods=['POST'])
def create_incident():
    data = request.get_json()

    reporter = data.get("reporter", "").strip()
    description = data.get("description", "").strip()

    if not reporter:
        return jsonify({"error": "El campo 'reporter' es obligatorio"}), 400
    if len(description) < 10:
        return jsonify({"error": "La descripción debe tener al menos 10 caracteres"}), 400

    incident = Incident(
        reporter=reporter,
        description=description,
        status=data.get("status", "Pendiente")
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

# Actualizar estado de un incidente
@app.route('/incidents/<int:incident_id>', methods=['PUT'])
def update_status(incident_id):
    incident = Incident.query.get(incident_id)
    if not incident:
        return jsonify({"error": "Incidente no encontrado"}), 404

    data = request.get_json()
    new_status = data.get("status", "").capitalize()

    if new_status not in ["Pendiente", "En proceso", "Resuelto"]:
        return jsonify({"error": "Estado inválido. Debe ser Pendiente, En proceso o Resuelto"}), 400

    incident.status = new_status
    db.session.commit()
    return jsonify(incident.to_dict())

if __name__ == '__main__':
    app.run(debug=True, port=3001)
