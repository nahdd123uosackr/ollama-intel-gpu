FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0
ENV LIBVA_DRIVER_NAME=iHD
ENV ONEAPI_DEVICE_SELECTOR=level_zero:0
ENV OLLAMA_NUM_GPU=999
ENV OLLAMA_NUM_PARALLEL=1
ENV SYCL_CACHE_PERSISTENT=1
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV no_proxy=localhost,127.0.0.1

# 기본 도구 설치
RUN apt-get update && apt-get install -y \
    git curl wget unzip ca-certificates gnupg lsb-release sudo \
    build-essential pciutils \
    intel-media-va-driver-non-free libva2 libdrm2 vainfo \
    && rm -rf /var/lib/apt/lists/*

# oneAPI 설치 (필요 시)
RUN mkdir -p /opt/intel && \
    curl -O https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9a20babe-3f91-4a63-8226-6d9d1b234a67/l_BaseKit_p_2024.1.0.585_offline.sh && \
    chmod +x l_BaseKit_p_2024.1.0.585_offline.sh && \
    ./l_BaseKit_p_2024.1.0.585_offline.sh -a --silent --eula accept \
        --install-dir=/opt/intel --components=intel.oneapi.runtime.dpcpp

# 환경변수 적용
RUN echo "source /opt/intel/oneapi/setvars.sh" >> /etc/bash.bashrc

# ipex-llm 기반 Ollama 실행 파일 설치
WORKDIR /opt/ollama
ARG IPEX_VER=v2.3.0-nightly
ARG ZIP_FILE=ollama-ipex-llm-2.3.0b20250415-ubuntu.tgz
RUN wget https://github.com/intel/ipex-llm/releases/download/${IPEX_VER}/${ZIP_FILE} && \
    tar -xzf ${ZIP_FILE} && rm ${ZIP_FILE}

ENV PATH="/opt/ollama/bin:$PATH"

# 미리 모델 다운로드
RUN ./ollama pull llama3

EXPOSE 11434
CMD ["./ollama", "serve"]
