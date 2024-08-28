#!/bin/bash

# File: install.sh

# Variables
REPO_URL="https://github.com/raison-dados/create-lambda-layer.git"  # Replace with your actual GitHub username
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="create-lambda-layer"
REPO_NAME="create-lambda-layer"

# Function to handle errors
error_exit() {
  echo "$1" >&2
  exit 1
}

# Check for sudo permissions before proceeding
if ! sudo -v; then
  error_exit "Error: You must have sudo privileges to install the script."
fi

# Clone the repository
echo "Cloning repository from $REPO_URL..."
if ! git clone "$REPO_URL"; then
  error_exit "Error: Failed to clone repository from $REPO_URL."
fi

# Navigate to the cloned directory
cd "$REPO_NAME" || error_exit "Error: Failed to change directory to $REPO_NAME."

cd "$REPO_NAME" || error_exit "Error: Failed to change directory to $REPO_NAME."

# Check if the script file exists
if [ ! -f "${SCRIPT_NAME}.sh" ]; then
  error_exit "Error: Script file '${SCRIPT_NAME}.sh' not found in the repository."
fi

# Copy the script to /usr/local/bin and make it executable
echo "Copying script to $INSTALL_DIR..."
if ! sudo cp "${SCRIPT_NAME}.sh" "$INSTALL_DIR/$SCRIPT_NAME"; then
  error_exit "Error: Failed to copy script to $INSTALL_DIR."
fi

echo "Setting executable permissions for the script..."
if ! sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"; then
  error_exit "Error: Failed to make script executable."
fi

echo "$SCRIPT_NAME installed successfully in $INSTALL_DIR."
echo "You can run it using the command '$SCRIPT_NAME'."
