# Get V8 source
FROM strimoid/depot-tools AS source
RUN fetch --no-history v8

# Build V8 source
FROM alpine:3.12 AS build

WORKDIR /usr/local/src
COPY --from=source /usr/local/src /usr/local/src

RUN apk add --no-cache --virtual .gn --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted gn && \
    apk add --no-cache --virtual .build-deps g++ gcc glib-dev icu-dev libstdc++ linux-headers make ninja pkgconf python2 && \
    ln -sf /usr/bin/gn /usr/local/src/v8/buildtools/linux64/gn && \
    cd v8 && \
    tools/dev/v8gen.py x64.release -- is_component_build=true is_cfi=false is_clang=false is_official_build=true use_custom_libcxx=false use_gold=false use_sysroot=false && \
    ln -sf /usr/bin/python2 /usr/bin/python3 && \
    ninja -C out.gn/x64.release -j $(getconf _NPROCESSORS_ONLN) d8 && \
    mkdir -p /v8/include /v8/lib && \
    cp -R include/* /v8/include && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /v8/lib && \
    strip -s /v8/lib/*.so && \
    rm -r /usr/local/src/v8 && \
    apk del .gn .build-deps
