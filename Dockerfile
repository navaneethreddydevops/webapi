# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

EXPOSE 8080

# Copy csproj and restore as distinct layers
COPY WebAPI/bin/Release/net5.0/ /app

# # # Copy everything else and build
# # COPY ../engine/examples ./
# # RUN dotnet publish -c Release -o out

# # Build runtime image
# FROM mcr.microsoft.com/dotnet/aspnet:3.1
# WORKDIR /app
# COPY --from=build-env /app/out .
# ENTRYPOINT ["dotnet", "aspnetapp.dll"]
ENTRYPOINT ["dotnet", "WebAPI.dll"]