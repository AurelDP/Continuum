# Use an official Maven image as a build stage
FROM maven:3.8.4-openjdk-17 AS build

# Arguments with default values in case they are not provided
ARG DOCKER_IMAGE_NAME=continuum
ARG JENKINS_BUILD_ID=0.0.1-SNAPSHOT

# Set the working directory
WORKDIR /app

# Copy the pom.xml for dependencies
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy the application code
COPY src src

# Build the application (generate a jar file with the version from Jenkins build)
RUN mvn package -Drevision="$JENKINS_BUILD_ID"


# Use a lightweight Java image for the runtime
FROM openjdk:17-slim

ARG DOCKER_IMAGE_NAME
ARG JENKINS_BUILD_ID

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage (jar version is from Jenkins build)
COPY --from=build /app/target/$DOCKER_IMAGE_NAME-$JENKINS_BUILD_ID.jar app.jar

# Expose the port
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
