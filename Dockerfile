FROM eclipse-temurin:21.0.2_13-jre-alpine as build
COPY . .
RUN ./gradlew build -x test

FROM eclipse-temurin:21

RUN mkdir -p /app /app/logs /app/tmp

ARG SOPS_AMD64="https://github.com/bekk/sops/releases/download/v3/sops-v3.linux.amd64"
ARG SOPS_ARM64="https://github.com/bekk/sops/releases/download/v3/sops-v3.linux.arm64"

ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -L $SOPS_AMD64 -o /usr/local/bin/sops; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -L $SOPS_ARM64 -o /usr/local/bin/sops; \
    else \
      echo "Unsupported architecture"; \
      exit 1; \
    fi \
    && chmod +x /usr/local/bin/sops

COPY --from=build /build/libs/*.jar /app/backend.jar

EXPOSE 8080 8081
ENTRYPOINT ["java", "-jar", "/app/backend.jar"]