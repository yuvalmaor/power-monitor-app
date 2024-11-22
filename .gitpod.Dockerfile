FROM gitpod/workspace-full:latest

# Install Java and Android tools
RUN apt-get update && apt-get install -y openjdk-11-jdk android-sdk
ENV ANDROID_HOME=/usr/lib/android-sdk
