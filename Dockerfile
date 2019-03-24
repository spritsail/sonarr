FROM spritsail/mono:4.5

ARG SONARR_VER=2.0.0.5319

ENV SUID=906 SGID=900

LABEL maintainer="Spritsail <sonarr@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Sonarr" \
      org.label-schema.url="https://sonarr.tv/" \
      org.label-schema.description="A TV show management and downloader tool" \
      org.label-schema.version=${SONARR_VER} \
      io.spritsail.version.sonarr=${SONARR_VER}

WORKDIR /sonarr

COPY *.sh /usr/local/bin/

RUN apk add --no-cache sqlite-libs libmediainfo xmlstarlet \
 && wget -O- "http://download.sonarr.tv/v2/master/mono/NzbDrone.master.${SONARR_VER}.mono.tar.gz" \
        | tar xz --strip-components=1 \
 && find -type f -exec chmod 644 {} + \
 && find -type d -o -name '*.exe' -exec chmod 755 {} + \
 && find -name '*.mdb' -delete \
# Remove unmanted js source-map files
 && find UI -name '*.map' -delete \
# These directories are in the wrong place
 && rm -rf UI/Content/_output \
# Where we're going, we don't need ~roads~ updates!
 && rm -rf NzbDrone.Update \
 && apk add --no-cache ca-certificates-mono \
 && update-ca-certificates \
 && apk del --no-cache ca-certificates-mono \
 && chmod +x /usr/local/bin/*.sh

VOLUME /config
ENV XDG_CONFIG_HOME=/config

EXPOSE 8989

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:8989/api/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/sonarr/NzbDrone.exe", "--no-browser", "--data=/config"]
