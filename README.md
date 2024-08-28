# Create Lambda Layer

`create-layer` is a Bash script that automates the process of creating an AWS Lambda layer from Python dependencies specified in a `requirements.txt` file. It generates a ZIP file containing the dependencies and uploads it as a new Lambda layer version using the AWS CLI.

## Features

- Automatically creates a Python Lambda layer ZIP file from specified dependencies.
- Supports specifying Python versions and custom output ZIP file names.
- Automatically deploys the Lambda layer to AWS and returns the Layer ARN.
- Cleans up intermediate files after the layer creation process.

## Prerequisites

- **AWS CLI**: Ensure that the AWS CLI is installed and configured on your system. You can install it from [AWS CLI Installation](https://aws.amazon.com/cli/).
- **Python**: Python and `pip` must be installed on your system.
- **Git**: To clone the repository.
- **Permissions**: AWS credentials configured with permissions to create Lambda layers (`lambda:PublishLayerVersion`).

## Installation

You can install `create-layer` directly from the GitHub repository using the following one-liner:

```bash
curl -sSL https://raw.githubusercontent.com/<your_username>/create-layer/main/install.sh | bash
