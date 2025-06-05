# Use a Node.js base image
FROM node:latest AS builder

# Install Git (required for build process)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

RUN npm cache clean --force && rm -rf node_modules package-lock.json && npm install

# Copy the rest of the application
COPY . .

# Create required directories and ensure shell is available
RUN mkdir -p caches && ls -la /bin/sh

# Build the application
RUN npm run build-full

# Stage 2: Use a lightweight Node.js Alpine image for serving
FROM node:alpine

# Copy built files from the previous stage
COPY --from=builder /app /app

# Expose the ports
EXPOSE 8080

# Set working directory to the built files
WORKDIR /app

# Command to serve the files using http-server
CMD ["npx", "http-server"]