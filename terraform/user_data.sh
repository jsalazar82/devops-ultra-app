#!/bin/bash

# Actualizar sistema
dnf update -y

# Instalar Docker y Nginx
dnf install -y docker nginx

# Iniciar y habilitar servicios
systemctl start docker
systemctl enable docker
systemctl start nginx
systemctl enable nginx

# Agregar usuario ec2-user al grupo docker
usermod -aG docker ec2-user

# Crear directorio de aplicación
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Crear aplicación Flask
cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "DevOps Ultra Sprint 🚀"

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

# Crear Dockerfile
cat <<EOF > Dockerfile
FROM python:3.9-slim
WORKDIR /app

RUN apt-get update && apt-get install -y curl

COPY app.py .
RUN pip install flask

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
EOF

# Construir imagen Docker
docker build -t flask-devops:v1 .

# Ejecutar contenedor con restart automático
docker run -d \
  -p 5000:5000 \
  --name flask-container \
  --restart unless-stopped \
  flask-devops:v1

# Configurar Nginx como reverse proxy
cat <<EOF > /etc/nginx/conf.d/flask.conf
server {
    listen 80;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Reiniciar Nginx
systemctl restart nginx