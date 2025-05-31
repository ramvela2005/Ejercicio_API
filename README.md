# 🚨 API de Gestión de Incidentes - Flask + PostgreSQL + Docker

Esta aplicación permite reportar y gestionar incidentes relacionados con equipos de trabajo. Incluye backend en Flask + PostgreSQL y un frontend visual conectado por Docker.

---

## 🐳 Tecnologías utilizadas

- Python 3.11
- Flask + Flask-SQLAlchemy
- PostgreSQL
- Docker + Docker Compose
- Nginx (para servir el frontend)

---

## 🚀 Cómo correr el proyecto (modo automático con Docker)

### 1. Cloná el repositorio

```bash
git clone https://github.com/tuusuario/Ejercicio_API.git
cd Ejercicio_API
```

### 2. Levantá todos los servicios

```bash
docker-compose up --build
```

### 3. Accedé desde tu navegador

- **Frontend (CRUD visual):** [http://localhost:8080]
- **API (Flask):** [http://localhost:3001]

> Las tablas se crean automáticamente al levantar el servicio.

---

## 🔧 Estructura del proyecto

```
.
├── API.py               # API Flask
├── requirements.txt     # Dependencias
├── dockerfile           # Imagen del backend
├── docker-compose.yml   # Orquestador de servicios
├── frontend/            # Carpeta con index.html y estilos
└── README.md
```

---

## 🧪 Endpoints disponibles

| Método | Endpoint             | Descripción                                 |
|--------|----------------------|---------------------------------------------|
| POST   | `/incidents`         | Crear un nuevo incidente                    |
| GET    | `/incidents`         | Obtener la lista de incidentes              |
| GET    | `/incidents/<id>`    | Obtener un incidente específico             |
| PUT    | `/incidents/<id>`    | Actualizar el estado de un incidente        |
| DELETE | `/incidents/<id>`    | Eliminar un incidente                       |

---

## 📝 Ejemplos de uso

### Crear incidente

**POST** `/incidents`
```json
{
  "reporter": "Alejo",
  "description": "La computadora no enciende en sala 2"
}
```

### Cambiar estado

**PUT** `/incidents/1`
```json
{
  "status": "Resuelto"
}
```

---

## 📏 Reglas de negocio

- `reporter` es obligatorio.
- `description` debe tener al menos 10 caracteres.
- Los estados válidos son: `Pendiente`, `En proceso`, `Resuelto`.
- Solo se puede modificar el campo `status`.
- Si el incidente no existe, devuelve `404 Not Found`.

---


## 🧑‍💻 Créditos

Proyecto realizado para la materia de **Base de Datos I** 💻 por Diego Ramírez y Nina Nájera.

