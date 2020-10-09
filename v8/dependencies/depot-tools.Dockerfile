FROM debian:buster-slim AS source

ENV PATH $PATH:/tmp/depot_tools
WORKDIR /usr/local/src

RUN apt-get update && \
    apt-get install -y bzip2 curl git g++ pkg-config python2.7 libicu-dev libpq-dev zlib1g-dev && \
    ln -s /usr/bin/python2.7 /usr/bin/python2 && \
    ln -s /usr/bin/python2.7 /usr/bin/python
RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools
