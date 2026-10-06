FROM ruby:4.0
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential gcc clang make git pkg-config ca-certificates curl xz-utils \
      libssl-dev zlib1g-dev libffi-dev libyaml-dev coreutils procps time \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN useradd -m -s /bin/bash gate && chown gate:gate /src
