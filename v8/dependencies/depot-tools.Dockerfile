FROM debian:bullseye-slim AS source

ENV PATH $PATH:/tmp/depot_tools
WORKDIR /usr/local/src

RUN apt-get update && \
    apt-get install -y bzip2 curl git g++ pkg-config procps python3 libicu-dev libpq-dev zlib1g-dev && \
    ln -s /usr/bin/python3 /usr/bin/python
RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools
