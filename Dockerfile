FROM debian:stretch-slim
LABEL mainatiner="Adam Dodman <adam.dodman@gmx.com>"

ENV UID=906 GID=900

ARG SONARR_TAG

ARG TINI_VERSION=v0.16.1
ARG SU_EXEC_VER=v0.2

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
ADD https://github.com/javabean/su-exec/releases/download/v0.2/su-exec.amd64 /sbin/su-exec

RUN apt-get update \
 && apt-get install -y libmono-cil-dev mediainfo xmlstarlet curl jq \
    \
 && chmod +x /sbin/su-exec /sbin/tini \
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
 && apt-get remove -y curl jq openssl \
 && apt-get autoremove -y

VOLUME ["/config", "/media"]

EXPOSE 8989

COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/sonarr/NzbDrone.exe", "--no-browser", "--data=/config"]
