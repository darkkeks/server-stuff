FROM nginx:alpine
EXPOSE 80
COPY darkkeks.me /usr/share/nginx/html
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html index.htm; location / { try_files $uri $uri/ =404; } }' > /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
