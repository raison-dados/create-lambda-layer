#!/bin/bash

# File: create-lambda-layer

# Default values
REQUIREMENTS_FILE="requirements.txt"
PYTHON_VERSION=$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
LAYER_NAME="python-dependencies-layer"        # Default layer name
ZIP_FILE="$LAYER_NAME.zip"  # Default random name for ZIP file
DESCRIPTION="AWS Lambda layer for Python dependencies"  # Default description
RUNTIME="python${PYTHON_VERSION}"             # AWS Lambda runtime

# Define cleanup function to remove the python/ folder
cleanup() {
  if [ -d "python" ]; then
    rm -rf python
  fi
}

# Set trap to execute cleanup function on script exit
trap cleanup EXIT

# Parse command-line options
while getopts ":f:-file:v:-version:n:-name:" opt; do
  case $opt in
    f | -file)
      REQUIREMENTS_FILE="$OPTARG"
      ;;
    v | -version)
      PYTHON_VERSION="$OPTARG"
      RUNTIME="python${PYTHON_VERSION}"
      ;;
    n | -name)
      LAYER_NAME="$OPTARG"
      ZIP_FILE="$LAYER_NAME.zip"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Verify that the requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "Error: Requirements file '$REQUIREMENTS_FILE' not found." >&2
  exit 1
fi

# Define the directory for Python packages based on the specified Python version
PACKAGE_DIR="python/lib/python${PYTHON_VERSION}/site-packages"

# Create the directory for Python packages
mkdir -p "$PACKAGE_DIR" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to create directory '$PACKAGE_DIR'." >&2
  exit 1
fi

# Log the packages that are going to be installed
echo "Installing packages from $REQUIREMENTS_FILE for Python $PYTHON_VERSION..."
echo "Packages to be installed:"
cat "$REQUIREMENTS_FILE" || {
  echo "Error: Unable to read '$REQUIREMENTS_FILE'." >&2
  exit 1
}

# Install Python dependencies
pip install -r "$REQUIREMENTS_FILE" --platform manylinux2014_x86_64 --target "$PACKAGE_DIR" --only-binary=:all: > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to install dependencies from $REQUIREMENTS_FILE." >&2
  exit 1
fi

# Log the installed packages
echo "Installed packages:"
pip freeze --path "$PACKAGE_DIR"
if [ $? -ne 0 ]; then
  echo "Error: Failed to list installed packages." >&2
  exit 1
fi

# Create a ZIP file of the Python packages
zip -r "$ZIP_FILE" python > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to create ZIP file '$ZIP_FILE'." >&2
  exit 1
fi

# Create AWS Lambda layer from the generated ZIP file
echo "Creating AWS Lambda layer '$LAYER_NAME'..."
LAYER_RESPONSE=$(aws lambda publish-layer-version --layer-name "$LAYER_NAME" --description "$DESCRIPTION" --zip-file "fileb://$ZIP_FILE" --compatible-runtimes "$RUNTIME" --output json)
if [ $? -ne 0 ]; then
  echo "Error: Failed to create AWS Lambda layer." >&2
  exit 1
fi

# Parse the ARN of the created layer from the response
LAYER_ARN=$(echo "$LAYER_RESPONSE" | grep -o '"LayerVersionArn": "[^"]*' | grep -o '[^"]*$')

# If everything is successful, disable the cleanup trap
trap - EXIT

# Remove the intermediate python/ folder
cleanup

# Output the deployed layer ARN
echo "AWS Lambda layer '$LAYER_NAME' created successfully."
echo "Layer ARN: $LAYER_ARN"
