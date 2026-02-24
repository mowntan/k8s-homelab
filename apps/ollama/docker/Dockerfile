FROM debian:bookworm-slim

ARG OLLAMA_VERSION=0.17.0
ARG TARGETARCH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Create user and group
RUN groupadd -g 6550 ollama && \
    useradd -u 6550 -g ollama -m -d /home/ollama -s /bin/sh ollama

# Download and install Ollama
RUN curl -fsSL "https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/ollama-linux-${TARGETARCH}.tar.zst" \
    | zstd -d | tar x -C /usr && \
    chmod +x /usr/bin/ollama

# Create data directory
RUN mkdir -p /models && \
    chown -R ollama:ollama /models

USER ollama

ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_MODELS=/models

VOLUME ["/models"]

EXPOSE 11434

CMD ["ollama", "serve"]
