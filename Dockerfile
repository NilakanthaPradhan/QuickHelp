FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy files from the quickhelp_backend folder
COPY quickhelp_backend/pom.xml .
COPY quickhelp_backend/src ./src

# Build the application
RUN mvn clean package -DskipTests

# Run the application
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
