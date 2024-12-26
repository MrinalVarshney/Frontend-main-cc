#!/bin/bash

# Define all path variables
REPO_DIR="/var/www/Frontend-main-cc"              # Root directory for the repository
FRONTEND_DIR="$REPO_DIR/mrinal-live"              # Path to the mrinal.live frontend project
WEBHOOK_LISTENER_DIR="$REPO_DIR/webHook-Listener" # Path to the webhook listener directory
BUILD_DIR="$FRONTEND_DIR/build"                   # Path to the build folder inside mrinal.live
GIT_REPO_URL="https://github.com/MrinalVarshney/Frontend-main-cc"  # GitHub repository URL

# Set GitHub Token (make sure it's exported before running the script)
GITHUB_TOKEN=${GITHUB_TOKEN}  # Use the exported environment variable

# Step 1: Navigate to the repository directory
cd $REPO_DIR || { echo "Failed to navigate to repository directory."; exit 1; }

# Step 2: Pull the latest changes from the repository using the GitHub token for authentication
echo "Pulling the latest changes from the repository..."
git pull https://$GITHUB_TOKEN@github.com/MrinalVarshney/Frontend-main-cc.git || { echo "Failed to pull from repository."; exit 1; }

# Step 3: Install dependencies for the frontend
echo "Installing frontend dependencies..."
cd $FRONTEND_DIR || { echo "Failed to navigate to frontend directory."; exit 1; }
npm install || { echo "Failed to install frontend dependencies."; exit 1; }

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

# Step 8: Install/update dependencies for the webhook listener
echo "Installing webhook listener dependencies..."
cd $WEBHOOK_LISTENER_DIR || { echo "Failed to navigate to webhook listener directory."; exit 1; }
npm install || { echo "Failed to install webhook listener dependencies."; exit 1; }

# Step 9: Restart the webhook listener service (PM2)
echo "Restarting webhook listener service..."
pm2 restart frontend-main-webHook-listener || { echo "Failed to restart frontend-main-webHook-listener."; exit 1; }

echo "Deployment successful!"
