FROM debian:bookworm-slim AS build-amd64

ARG LLAMA_CPP_VERSION=8148

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/ggml-org/llama.cpp/releases/download/b${LLAMA_CPP_VERSION}/llama-b${LLAMA_CPP_VERSION}-bin-ubuntu-x64.tar.gz" \
    | tar xz -C /tmp && \
    mkdir -p /out && \
    cp /tmp/build/bin/llama-server /out/llama-server && \
    cp /tmp/build/bin/llama-rpc-server /out/llama-rpc-server

# ─────────────────────────────────────────────
FROM debian:bookworm-slim AS build-arm64

ARG LLAMA_CPP_VERSION=8148

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    cmake \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch b${LLAMA_CPP_VERSION} \
    https://github.com/ggml-org/llama.cpp.git /build && \
    cmake -B /build/build /build \
        -DLLAMA_BUILD_TESTS=OFF \
        -DBUILD_SHARED_LIBS=OFF && \
    cmake --build /build/build --target llama-server llama-rpc-server -j$(nproc) && \
    mkdir -p /out && \
    cp /build/build/bin/llama-server /out/llama-server && \
    cp /build/build/bin/llama-rpc-server /out/llama-rpc-server

# ─────────────────────────────────────────────
FROM build-${TARGETARCH} AS binaries

# ─────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 6551 llama && \
    useradd -u 6551 -g llama -m -d /home/llama -s /bin/sh llama

COPY --from=binaries /out/llama-server /usr/local/bin/llama-server
COPY --from=binaries /out/llama-rpc-server /usr/local/bin/llama-rpc-server

RUN chmod +x /usr/local/bin/llama-server /usr/local/bin/llama-rpc-server && \
    mkdir -p /models && \
    chown -R llama:llama /models

USER llama

VOLUME ["/models"]

# coordinator port
EXPOSE 8080
# rpc worker port
EXPOSE 50052
