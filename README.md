# 🚨 API de Gestión de Incidentes - Flask + PostgreSQL

Esta API permite a los empleados reportar y gestionar incidentes relacionados con sus equipos de trabajo (computadoras, redes, impresoras, etc).

## Tecnologías usadas

- Python 3.13
- Flask
- Flask SQLAlchemy
- PostgreSQL

## Instalación y configuración

1. Clona este repositorio:
```bash
git clone https://github.com/tuusuario/Ejercicio_API.git
```

2. Navega al directorio:
```bash
cd Ejercicio_API
```

3. Crea un entorno virtual (opcional pero recomendado):
```bash
python -m venv venv
.\venv\Scripts\activate
```

4. Instala las dependencias:
```bash
pip install -r requirements.txt
```

## 🛠️ Configuración de base de datos

1. Crea una base de datos llamada `incidentes_db` en PostgreSQL.
2. Crea un usuario con contraseña (ej: `apiuser` / `apipassword`) y asignale permisos de conexión, uso y creación sobre el esquema `public`.
3. Asegurate de tener algo así en tu archivo `API.py`:

```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://apiuser:apipassword@localhost:5432/incidentes_db'
```

4. Ejecuta el siguiente script para crear las tablas:
```bash
python create_tables.py
```

## ▶️ Correr la API

```bash
python API.py
```

Abre tu navegador en: [http://localhost:3001](http://localhost:3001)

## Endpoints disponibles

| Método | Endpoint             | Descripción                                 |
|--------|----------------------|---------------------------------------------|
| POST   | `/incidents`         | Crear un nuevo incidente                    |
| GET    | `/incidents`         | Obtener la lista de incidentes              |
| GET    | `/incidents/<id>`    | Obtener un incidente específico             |
| PUT    | `/incidents/<id>`    | Actualizar el estado de un incidente        |
| DELETE | `/incidents/<id>`    | Eliminar un incidente                       |

## Ejemplos de uso

### Crear incidente

**POST** `/incidents`  
```json
{
  "reporter": "Alejo",
  "description": "La computadora no enciende en sala 2"
}
```

### Actualizar estado

**PUT** `/incidents/1`  
```json
{
  "status": "Resuelto"
}
```

## 📏 Reglas de negocio

- `reporter` es obligatorio.
- `description` debe tener al menos 10 caracteres.
- Solo se puede modificar el campo `status`.
- Los estados válidos son: `Pendiente`, `En proceso`, `Resuelto`.
- Si el incidente no existe, devuelve `404 Not Found`.

## 📂 Archivo `requirements.txt`

Crea un archivo llamado `requirements.txt` con este contenido:

```
flask
flask_sqlalchemy
psycopg2-binary
```

Instalalo con:

```bash
pip install -r requirements.txt
```

## Créditos

Este proyecto fue desarrollado para la materia de **Tecnologías Web** 💻 por Diego Ramirez