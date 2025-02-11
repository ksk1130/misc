# [Optional] If you want to install additional packages, you can add them here
FROM mcr.microsoft.com/vscode/devcontainers/python:3.13

# Install any additional packages you want here
# RUN apt-get update && apt-get install -y <package-name>
RUN pip install --upgrade pip

# Install AWS CLI
RUN apt-get update && apt-get install -y curl unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
