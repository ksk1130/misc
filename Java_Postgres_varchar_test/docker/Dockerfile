FROM alpine:latest

run apk update
run apk add openjdk8
run apk add tzdata
run rm -rf /var/cache/apk/*

# Javaのパス設定
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/
ENV PATH="$JAVA_HOME/bin:$PATH"

# タイムゾーンの設定
run cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
run echo "Asia/Tokyo" > /etc/timezone
run apk del tzdata

COPY src/ /tmp/src/
COPY conf/ /tmp/conf/
WORKDIR /tmp
run javac -d /tmp /tmp/src/postgres_varchartest/Main.java
cmd ["java", "-cp", ".", "postgres_varchartest/Main"]
