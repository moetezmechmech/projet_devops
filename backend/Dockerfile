FROM python:3.9-slim    

# Installer curl pour le HEALTHCHECK et les scripts de contrôle
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root 'app'
RUN useradd --create-home --shell /bin/bash app

WORKDIR /home/app

# Installer les dépendances
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt 

# Copier le code de l'application
COPY app/ .

# Permissions pour l'utilisateur non-root
RUN chown -R app:app /home/app && chmod +x start.sh

# Basculer vers l'utilisateur non-root
USER app

EXPOSE 5000

# Instruction HEALTHCHECK demandée par le professeur (Atelier 3)
HEALTHCHECK --interval=20s --timeout=5s --retries=3 --start-period=10s \
  CMD curl -f http://localhost:5000/health || exit 1

CMD ["./start.sh"]
