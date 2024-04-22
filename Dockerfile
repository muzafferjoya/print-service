# Use the latest LTS version of Node.js with a recent Debian version as the base image
FROM node:18-bullseye-slim

# Maintainer information
LABEL maintainer="Muzaffar khan <muzafferjoya@gmail.com>"

# Switch to root user to perform installations
USER root

# Copy the source code into the container
COPY src /opt/print-service/

# Set working directory
WORKDIR /opt/print-service/

# Install dependencies
RUN npm install --unsafe-perm

# Install necessary packages for Google Chrome and fonts
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    fonts-indic \
    gnupg \
    ca-certificates \
    --no-install-recommends \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the service
RUN groupadd -r sunbird && useradd -r -g sunbird -G audio,video sunbird \
    && mkdir -p /home/sunbird/Downloads \
    && chown -R sunbird:sunbird /home/sunbird

# Clear font cache
RUN fc-cache -f -v

# Switch back to non-root user
USER sunbird

# Set environment variable
ENV NODE_ENV production

# Start the application
CMD ["node", "app.js"]
