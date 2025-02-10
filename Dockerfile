# Base image for ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["CI_CD.csproj", "."]
RUN dotnet restore "./CI_CD.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./CI_CD.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./CI_CD.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage (Production image)
FROM base AS final

# Step 1: Setup application
WORKDIR /app
COPY --from=publish /app/publish .

# Step 2: Add GitHub Actions Runner
WORKDIR /actions-runner

# Download and extract the GitHub Actions Runner
USER root
RUN apt-get update && apt-get install -y curl jq git
RUN curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz
RUN echo "ba46ba7ce3a4d7236b16fbe44419fb453bc08f866b24f04d549ec89f1722a29e  actions-runner-linux-x64-2.321.0.tar.gz" | sha256sum -c
RUN tar xzf actions-runner-linux-x64-2.321.0.tar.gz
RUN rm actions-runner-linux-x64-2.321.0.tar.gz

# Fix permissions for app user
RUN chown -R app:app /actions-runner

# Copy and configure entrypoint script
COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh

# Switch back to app user
USER app

# Entrypoint for the container
ENTRYPOINT ["/actions-runner/entrypoint.sh"]

# step 1: build the docker
# docker build -t github-actions-runner .
# run it
#docker run -d -e RUNNER_URL=https://github.com/InsoftDev012/CI_CD -e RUNNER_TOKEN=<your token> --name github-actions-runner github-actions-runner


