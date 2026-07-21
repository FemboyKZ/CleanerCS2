FROM registry.gitlab.steamos.cloud/steamrt/sniper/sdk:latest AS build

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        git \
        cmake \
    && git clone http://github.com/alliedmodders/ambuild \
    && pip3 install ./ambuild \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc CXX=g++

# Build abseil then re2 as static, position-independent libs into a shared prefix.
RUN git clone --depth 1 -b 20260526.0 https://github.com/abseil/abseil-cpp /tmp/absl && \
    cmake -S /tmp/absl -B /tmp/absl/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
        -DABSL_PROPAGATE_CXX_STD=ON \
        -DABSL_ENABLE_INSTALL=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/re2 && \
    cmake --build /tmp/absl/build -j"$(nproc)" --target install && \
    git clone --depth 1 -b 2025-11-05 https://github.com/google/re2 /tmp/re2 && \
    cmake -S /tmp/re2 -B /tmp/re2/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DRE2_BUILD_TESTING=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" \
        -DCMAKE_PREFIX_PATH=/opt/re2 \
        -DCMAKE_INSTALL_PREFIX=/opt/re2 && \
    cmake --build /tmp/re2/build -j"$(nproc)" --target install && \
    rm -rf /tmp/re2 /tmp/absl

ENV RE2_ROOT=/opt/re2

WORKDIR /src
COPY . .

RUN mkdir -p build && cd build && \
    python3 ../configure.py \
        --sdks cs2 \
        --targets x86_64 \
        --mms_path ../metamod-source \
        --hl2sdk-manifests ../metamod-source/hl2sdk-manifests \
        --re2-root /opt/re2 \
        --enable-optimize

RUN cd build && ambuild

# Minimal image carrying just the packaged artifact.
FROM alpine:latest AS output

COPY --from=build /src/build/package /package

CMD ["sh", "-c", "cp -r /package/* /output/"]
