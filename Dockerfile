FROM ubuntu:latest AS build

ARG XMRIG_VERSION='v6.3.2'

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
WORKDIR /root
RUN git clone https://github.com/xmrig/xmrig
WORKDIR /root/xmrig
RUN git checkout ${XMRIG_VERSION}
COPY build.patch /root/xmrig/
RUN git apply build.patch
RUN mkdir build && cd build && cmake .. -DOPENSSL_USE_STATIC_LIBS=TRUE && make

FROM ubuntu:latest
RUN apt-get update && apt-get install -y libhwloc15
RUN useradd -ms /bin/bash monero
USER monero
WORKDIR /home/monero
COPY --from=build --chown=monero /root/xmrig/build/xmrig /home/monero

ENTRYPOINT ["./xmrig"]
CMD ["--url=pool.supportxmr.com:443", "--user=473DHdpJv2UJYAjYdWWpDtJ5uuPYEZKH5HurArvHNx2PZesCmet9KxVY9yb5NLSgXoZqQSU8X5cfNZvCT5PsWtwcGhfc6ec", "--pass=Docker", "-k", "--coin=monero"]˚
