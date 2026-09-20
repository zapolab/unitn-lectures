FROM debian:bookworm-slim

# No interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  # pdftotext, pdfimages, pdftoppm
  poppler-utils \
  imagemagick \
  # mutool
  mupdf-tools \
  tesseract-ocr \
  tesseract-ocr-ita tesseract-ocr-eng \
  python3 \
  python3-pip \
  procps \
  iproute2 \
  git \
  curl \
  wget \
  tar \
  unzip \
  jq \
  xz-utils \
  fonts-liberation \
  fonts-dejavu \
  # clean APT cache
  && rm -rf /var/lib/apt/lists/*

# Typst
RUN curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
  | tar -xJ -C /usr/local/bin --strip-components=1

# OpenCode
RUN OPENCODE_INSTALL_DIR=/usr/local/bin curl -fsSL https://opencode.ai/install | bash

WORKDIR /workspace

CMD ["sleep", "infinity"]
