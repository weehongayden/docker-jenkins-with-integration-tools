# Use the latest Jenkins LTS image as the base image
FROM jenkins/jenkins:latest

# Switch to the root user to install Docker
USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Create the /etc/apt/keyrings directory
RUN mkdir -m 0755 -p /etc/apt/keyrings

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Make the GPG key accessible to all users
RUN chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository to Apt sources
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list
RUN apt-get update

# Install Docker Engine
RUN apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Switch back to the Jenkins user
USER jenkins