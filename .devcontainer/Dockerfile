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
  ripgrep \
  fonts-liberation \
  fonts-dejavu \
  # clean APT cache
  && rm -rf /var/lib/apt/lists/*

# PyMuPDF
RUN pip3 install --no-cache-dir --break-system-packages pymupdf

# Typst
RUN curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-aarch64-unknown-linux-musl.tar.xz \
  | tar -xJ -C /usr/local/bin --strip-components=1

# OpenCode
RUN curl -fsSL https://opencode.ai/install | bash
RUN cp /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    chmod 755 /usr/local/bin/opencode

# dev user
RUN groupadd -g 1000 dev && \
    useradd -u 1000 -g dev -m -s /bin/bash dev

USER dev
WORKDIR /workspace

CMD ["sleep", "infinity"]
