FROM swift:5.9-jammy AS build

WORKDIR /build

COPY Package.swift Package.resolved ./

RUN swift package resolve

COPY Sources ./Sources

RUN swift build \
    --configuration release \
    --static-swift-stdlib

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    libatomic1 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build \
    /build/.build/release/ProntoTixBackend \
    /app/ProntoTixBackend

ENV ENVIRONMENT=production

EXPOSE 8080

CMD ["./ProntoTixBackend"]