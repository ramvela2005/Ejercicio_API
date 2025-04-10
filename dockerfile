# Imagen base
FROM python:3.11-slim

# Establece directorio de trabajo
WORKDIR /app

# Copia los archivos
COPY . /app

# Instala dependencias
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Expone el puerto de Flask
EXPOSE 3001

# Comando por defecto para correr la app
CMD ["python", "API.py"]
