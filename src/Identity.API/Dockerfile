#FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
#WORKDIR /app
#
#FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
#WORKDIR /src
#COPY ["Services/IdentityServer/src/AW.Services.IdentityServer/AW.Services.IdentityServer.csproj", "Services/IdentityServer/src/AW.Services.IdentityServer/"]
#COPY Services/IdentityServer/src/AW.Services.IdentityServer/identityserver.pfx .
#RUN dotnet restore "Services/IdentityServer/src/AW.Services.IdentityServer/AW.Services.IdentityServer.csproj"
#COPY . .
#WORKDIR "/src/Services/IdentityServer/src/AW.Services.IdentityServer"
#RUN dotnet build "AW.Services.IdentityServer.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "AW.Services.IdentityServer.csproj" -c Release -o /app/publish
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#COPY --from=build /src/identityserver.pfx .
#ENTRYPOINT ["dotnet", "AW.Services.IdentityServer.dll"]






FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY . ./

RUN dotnet restore src/Identity.API/Identity.API.csproj

FROM build AS publish
RUN dotnet publish src/Identity.API/Identity.API.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=publish /app/out .
COPY --from=build /src/Identity.API/tempkey.jwk .
ENTRYPOINT ["dotnet", "Identity.API.dll"]
