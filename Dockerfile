# Most of this is copied from SwiftLint's Dockerfile because I don't
# really know how to use Docker or Swift on Linux

ARG BUILDER_IMAGE=swift:latest
ARG RUNTIME_IMAGE=swift:slim

# Builder image
FROM ${BUILDER_IMAGE} AS builder
WORKDIR /workdir/
COPY Source Source/
COPY Package.* ./

ARG SWIFT_FLAGS="-c release -Xswiftc -static-stdlib -Xswiftc -I. -Xlinker -fuse-ld=lld -Xlinker -L/usr/lib/swift/linux"
RUN swift build $SWIFT_FLAGS
RUN mkdir -p /executables
RUN for executable in $(swift package completion-tool list-executables); do \
        install -v `swift build $SWIFT_FLAGS --show-bin-path`/$executable /executables; \
    done

# rumtime image
FROM ${RUNTIME_IMAGE}
LABEL org.opencontainers.image.source https://github.com/Apple-Actions/reviewdog-action-xcode-issues

ENV REVIEWDOG_VERSION=v0.14.0

RUN apt-get update && apt-get install -y \
  wget \
  git \
  && rm -r /var/lib/apt/lists/*

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

COPY --from=builder /usr/lib/swift/linux/libBlocksRuntime.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libdispatch.so /usr/lib
COPY --from=builder /executables/* /usr/bin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
