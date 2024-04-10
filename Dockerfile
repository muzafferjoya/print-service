# Use Debian Stretch as the base image
FROM node:8.11-slim

# Maintainer information
LABEL maintainer="Mahesh Kumar Gangula <mahesh@ilimi.in>"

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
    google-chrome-unstable \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
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
