docker pull python:3.9-slim

docker build -t python_argtest -f docker/Dockerfile_python_argtest --build-arg CPU_ARCH='aarch64' .
