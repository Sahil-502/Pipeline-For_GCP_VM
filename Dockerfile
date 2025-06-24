# Use the official Nginx base image
FROM nginx:latest

# Copy a custom index.html file to the default Nginx root directory
COPY index.html /usr/share/nginx/html/

# Expose port 82
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

# You can add new config
