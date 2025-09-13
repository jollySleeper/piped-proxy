# syntax=docker/dockerfile:1.5
ARG TARGETARCH

FROM rust:slim AS build
ARG TARGETARCH

WORKDIR /app/

COPY . .

RUN --mount=type=cache,id=apt-${TARGETARCH},target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      nasm && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,id=cargo-reg-${TARGETARCH},target=/usr/local/cargo/registry \
    --mount=type=cache,id=target-${TARGETARCH},target=/app/target \
    cargo build --release && \
    mv target/release/piped-proxy .


FROM debian:stable-slim AS runtime
ARG TARGETARCH

RUN --mount=type=cache,id=apt-${TARGETARCH},target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY --from=build /app/piped-proxy .

EXPOSE 8080

CMD ["/app/piped-proxy"]
