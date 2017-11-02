FROM xataz/mono:latest
LABEL maintainer="Adam Dodman <adam.dodman@gmx.com>"

ENV UID=906 GID=900

ARG SONARR_TAG

RUN echo '@commuedge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
 && apk --no-cache add mediainfo@commuedge sqlite-libs xmlstarlet su-exec tini \
 && apk --no-cache add -t build_deps curl jq openssl \
    \
 && if [ -z "$SONARR_TAG" ]; then \
        export SONARR_TAG="$(curl -fL "https://api.github.com/repos/Sonarr/Sonarr/tags" | jq -r '.[0].name')"; \
    fi \
 && mkdir -p /sonarr \
 && echo "Building Sonarr $SONARR_TAG" \
 && curl -fL "http://download.sonarr.tv/v2/master/mono/NzbDrone.master.${SONARR_TAG#v}.mono.tar.gz" \
        | tar xz -C /sonarr --strip-components=1 \
 && find /sonarr -type f -exec chmod 644 {} + \
 && find /sonarr -type d -o -name '*.exe' -exec chmod 755 {} + \
    \
 && apk --no-cache del build_deps

VOLUME ["/config", "/media"]

EXPOSE 8989

COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/sonarr/NzbDrone.exe", "--no-browser", "--data=/config"]
