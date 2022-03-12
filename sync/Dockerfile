FROM alpine:latest

LABEL maintainer="edoshor@gmail.com"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        openssh-client \
        rsync && \
    rm -rf /var/cache/apk/*

VOLUME ["/data"]

ADD sync.sh /sync.sh
CMD /sync.sh
