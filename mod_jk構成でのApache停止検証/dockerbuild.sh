docker compose -f dockerfiles/docker-compose.yml down
docker build -t httpd-container -f dockerfiles/Dockerfile_apache .
docker build -t tomcat-container -f dockerfiles/Dockerfile_tomcat .
docker compose -f dockerfiles/docker-compose.yml up -d

