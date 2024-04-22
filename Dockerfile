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
    --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    ... # Rest of the packages remain the same
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the service
RUN groupadd -r sunbird && useradd -r -g sunbird -G audio,video sunbird \
    && mkdir -p /home/sunbird/Downloads \
    && chown -R sunbird:sunbird /home/sunbird

# Clear font cache
RUN fc-cache -f -v

# Switch back to non-root user
USER sunbird

# Copy the source code from the build stage
COPY --from=build --chown=sunbird /opt/print-service/ /home/sunbird/print-service/

# Set working directory
WORKDIR /home/sunbird/print-service/

# Create a directory for certificates
RUN mkdir /home/sunbird/print-service/certs

# Set environment variable
ENV NODE_ENV production

# Start the application
CMD ["node", "app.js"]
