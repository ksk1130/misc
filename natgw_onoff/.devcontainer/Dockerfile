FROM python:3.13-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl unzip
RUN pip install --upgrade pip

COPY .devcontainer/requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

