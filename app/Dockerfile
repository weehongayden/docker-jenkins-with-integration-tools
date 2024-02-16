FROM maven:3.9.4-amazoncorretto-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src/ /app/src/
RUN mvn clean package -DskipTests

FROM amazoncorretto:17.0.8-alpine3.18
WORKDIR /app
COPY --from=build /app/target/inchfab-api.jar .
EXPOSE 8080
ENTRYPOINT ["java","-jar","inchfab-api.jar"]