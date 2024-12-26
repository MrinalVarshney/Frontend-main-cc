#!/bin/bash

# Define all path variables
REPO_DIR="/var/www/Frontend-cc-main/mrinal.live"  # Path to the mrinal.live project
BUILD_DIR="$REPO_DIR/build"                       # Path to the build folder inside the project
GIT_REPO_URL="https://github.com/MrinalVarshney/Frontend-main-cc"  # GitHub repository URL
WEBHOOK_LISTENER_DIR="/var/www/Frontend-cc-main/webHook-Listener"  # Path to the webhook listener

# Set GitHub Token 
GITHUB_TOKEN=${GITHUB_TOKEN}  

# Step 1: Navigate to the mrinal.live directory
cd $REPO_DIR || { echo "Failed to navigate to mrinal.live directory."; exit 1; }

# Step 2: Pull the latest changes from the repository using the GitHub token for authentication
echo "Pulling the latest changes from the repository..."
git pull https://$GITHUB_TOKEN@github.com/MrinalVarshney/Frontend-main-cc.git || { echo "Failed to pull from repository."; exit 1; }

# Step 3: Install dependencies for the frontend
echo "Installing frontend dependencies..."
npm install || { echo "Failed to install frontend dependencies."; exit 1; }

# Step 4: Build the React app
echo "Building the React app..."
npm run build || { echo "Build failed."; exit 1; }

# Step 5: Update the Nginx directory with the new build
echo "Copying built files to Nginx directory..."
sudo cp -r $BUILD_DIR/* /var/www/Frontend-cc-main/build/ || { echo "Failed to copy build files to Nginx directory."; exit 1; }

# Step 6: Ensure the correct permissions for the Nginx user
echo "Setting permissions for Nginx..."
sudo chown -R www-data:www-data /var/www/Frontend-cc-main/build || { echo "Failed to set permissions."; exit 1; }

# Step 7: Reload Nginx to serve the new build
echo "Reloading Nginx..."
sudo systemctl reload nginx || { echo "Failed to reload Nginx."; exit 1; }

# Step 8: Pull the latest changes for the webhook listener 
echo "Pulling the latest changes for webhook listener..."
cd $WEBHOOK_LISTENER_DIR || { echo "Failed to navigate to webhook listener directory."; exit 1; }
git pull https://$GITHUB_TOKEN@github.com/MrinalVarshney/webhook-listener-repo.git || { echo "Failed to pull for webhook listener."; exit 1; }

# Step 9: Install/update dependencies for the webhook listener
echo "Installing webhook listener dependencies..."
npm install || { echo "Failed to install webhook listener dependencies."; exit 1; }

# Step 10: Restart the webhook listener service (PM2)
echo "Restarting webhook listener service..."
pm2 restart frontend-main-webHook-listener || { echo "Failed to restart webhook listener."; exit 1; }

echo "Deployment successful!"
