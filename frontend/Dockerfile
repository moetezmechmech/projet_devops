FROM nginx:alpine

# Copie des fichiers frontend et de configuration
COPY . /usr/share/nginx/html
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./config.template.js /usr/share/nginx/html/config.js
COPY ./start.sh /start.sh

# Permissions
RUN chmod +x /start.sh && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /usr/share/nginx/html

EXPOSE 80

# Instruction HEALTHCHECK demandée par le professeur (Atelier 3)
HEALTHCHECK --interval=20s --timeout=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:80/ || exit 1

CMD ["./start.sh"]
