ARG ALPINE_VERSION="3.13"

FROM alpine:${ALPINE_VERSION} AS builder
ARG PGBOUNCER_VERSION=1.15.0
WORKDIR /build
# Install packages needed to compile pgbouncer. Note: we use c-ares because is is the most fully-featured implementation of DNS lookup. See https://www.pgbouncer.org/install.html
RUN apk add --no-cache make g++ libevent-dev pkgconfig openssl-dev c-ares-dev curl
# Download and extract pgbouncer
RUN curl -o pgbouncer-${PGBOUNCER_VERSION}.tar.gz -L https://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz && tar -xf pgbouncer-${PGBOUNCER_VERSION}.tar.gz
# Build pgbouncer binary
RUN mv pgbouncer-${PGBOUNCER_VERSION}/* . && ./configure && make

# TODO: consider using scratch
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Allan Ramirez <ramirezag@gmail.com>"
LABEL description="Docker image for pgbouncer"
COPY --from=builder /build/pgbouncer /usr/local/bin
COPY *.ini /etc/pgbouncer/
COPY pgbouncer.sh /usr/local/bin/
# Install minimum package requirements to run pgbouncer. Bash is needed for scripting in pgbouncer.sh
RUN apk add libevent c-ares bash && chmod +x /usr/local/bin/pgbouncer.sh
CMD ["/usr/local/bin/pgbouncer.sh"]
ENTRYPOINT ["/bin/sh", "-c"]
