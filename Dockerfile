# Builder

FROM abiosoft/caddy:builder as builder

ARG version="0.11.0"
ARG plugins="cors,realip,expires,cache,nobots"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh


# Final stage

FROM alpine:3.8

ARG version="0.11.0"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 2015

VOLUME /root/.caddy
COPY Caddyfile /etc/Caddyfile

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]
