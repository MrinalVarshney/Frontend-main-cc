#!/bin/bash

# Define all path variables
REPO_DIR="/var/www/Frontend-main-cc/mrinal-live"  
BUILD_DIR="$REPO_DIR/build"           
GIT_REPO_URL="https://github.com/MrinalVarshney/Frontend-main-cc"  

# Step 1: Navigate to the project directory
cd $REPO_DIR || { echo "Failed to navigate to project directory."; exit 1; }

# Step 2: Pull the latest changes from the repository
echo "Pulling the latest changes from the repository..."
git pull origin main || { echo "Failed to pull from repository."; exit 1; }

# Step 3: Install dependencies
echo "Installing dependencies..."
npm install || { echo "Failed to install dependencies."; exit 1; }

# Step 4: Build the React app
echo "Building the React app..."
npm run build || { echo "Build failed."; exit 1; }

# Step 5: Update the Nginx directory with the new build
echo "Copying built files to Nginx directory..."
sudo cp -r $BUILD_DIR/* /var/www/Frontend-main-cc/build/ || { echo "Failed to copy build files to Nginx directory."; exit 1; }

# Step 6: Ensure the correct permissions for the Nginx user
echo "Setting permissions for Nginx..."
sudo chown -R www-data:www-data /var/www/Frontend-main-cc/build || { echo "Failed to set permissions."; exit 1; }

# Step 7: Reload Nginx to serve the new build
echo "Reloading Nginx..."
sudo systemctl reload nginx || { echo "Failed to reload Nginx."; exit 1; }

echo "Deployment successful!"
