FROM intelanalytics/ipex-llm-inference-cpp-xpu:latest

# 환경변수 설정
ENV OLLAMA_HOST=0.0.0.0 \
    OLLAMA_NUM_GPU=999 \
    no_proxy=localhost,127.0.0.1 \
    ZES_ENABLE_SYSMAN=1 \
    SYCL_CACHE_PERSISTENT=1 \
    SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1 \
    ONEAPI_DEVICE_SELECTOR=level_zero:0
    
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
