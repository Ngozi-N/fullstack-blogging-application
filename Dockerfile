FROM eclipse-temurin:17-jdk-alpine

EXPOSE 8080

ENV APP_HOME /usr/src/app

WORKDIR $APP_HOME

COPY target/*.jar ./  # <-- Copy all .jar files into the working directory

CMD ["sh", "-c", "java -jar *.jar"]  # <-- Run the actual JAR found

