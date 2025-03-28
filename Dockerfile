FROM alpine:3.21.3

ENV PUSH_USER_NAME=push
ENV PUSH_USER_UID=1000
ENV PUSH_USER_GID=1000

ENV PULL_USER_NAME=pull
ENV PULL_USER_UID=1001
ENV PULL_USER_GID=1001

EXPOSE 22

VOLUME /share
VOLUME /etc/ssh/keys

RUN apk add --no-cache \
    tini \
    openssh \
    rsync

COPY --chmod=770 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]