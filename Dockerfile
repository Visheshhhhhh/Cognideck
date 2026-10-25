# Production-ready Dockerfile for Cognideck
FROM nginx:alpine

# Metadata
LABEL maintainer="Vishesh Shah <1262243217>"
LABEL project="Cognideck - CCA 2 DevOps Assignment"

# Remove default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy web assets to Nginx html root
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/

# Expose application port
EXPOSE 80

# Healthcheck to verify web server responsiveness
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
