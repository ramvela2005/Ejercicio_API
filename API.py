from flask import Flask, request, jsonify

app = Flask(__name__)

# Base de datos simulada
incidents = [
    {"id": 1, "Reporter": "Persona1", "description": "Falta de luz en clase 1", "status": "Pendiente", "created_at": "2023-10-01"},
    {"id": 2, "Reporter": "Persona2", "description": "base de datos error", "status": "En progreso", "created_at": "2023-10-02"},
    {"id": 3, "Reporter": "Persona3", "description": "Fuga de información", "status": "Resuelto", "created_at": "2023-10-03"},
    {"id": 4, "Reporter": "Persona4", "description": "fuera de señal en salon 3", "status": "Pendiente", "created_at": "2023-10-04"},
    {"id": 5, "Reporter": "Persona5", "description": "fallo en camara", "status": "En progreso", "created_at": "2023-10-05"},
]

#pantalla de info 
@app.route('/', methods=['GET'])
def Welcome_screen():
    return jsonify({
        "message": "Bienvenido a la API de incidentes",
        "endpoints": {
            "POST /incidents": "Crear un nuevo incidente",
            "GET /incidents": "Obtener lista de incidentes ",
            "GET /incidents/<int:id>": "Obtener un incidente en especifico ",
            "PUT /incidents/<int:id>": "Actualizar el estado de un incidente",
            "DELETE /incidents/<int:id>": "Eliminar un incidente reportado por error",
        }
    })


#Crear un nuevo incident
@app.route('/incidents', methods=['POST'])
def create_incident():
    new_incident = request.json
    
    if "Reporter" not in new_incident or not new_incident ["Reporter"].strip():
        return jsonify({"error": "El campo 'Reporter' es obligatorio"}), 400
    
    if "description" not in new_incident or len(new_incident["description"]) < 10:
        print(new_incident["description"])
        return jsonify({"error": "La 'description' debe tener al menos 10 caracteres"}), 400
    
    #nueva estructura de incident
    new_incident = {
        "id": len(incidents) + 1,
        "Reporter": new_incident["Reporter"],
        "description": new_incident["description"],
        "status": new_incident.get("status", "Pendiente"),
        "created_at": new_incident.get("created_at", "") 
    }
    
    incidents.append(new_incident)
    return jsonify(new_incident), 201


# Obtener todos los incidents
@app.route('/incidents', methods=['GET'])
def get_posts():
    return jsonify(incidents)



if __name__ == '__main__':
    app.run(debug=True, port=3001)