FROM spritsail/mono:4.5

ARG SONARR_VER=3.0.5.1144

ARG SONARR_BRANCH=main

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

RUN apk add --no-cache ca-certificates-mono sqlite-libs libmediainfo xmlstarlet \
 && wget -O- "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VER}/Sonarr.${SONARR_BRANCH}.${SONARR_VER}.linux.tar.gz" \
        | tar xz --strip-components=1 \
 && find -type f -exec chmod 644 {} + \
 && find -type d -o -name '*.exe' -exec chmod 755 {} + \
 && find -name '*.mdb' -delete \
# Where we're going, we don't need ~roads~ updates!
 && rm -r Sonarr.Update \
 && chmod +x /usr/local/bin/*.sh

VOLUME /config
ENV XDG_CONFIG_HOME=/config

EXPOSE 8989

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:8989/api/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/sonarr/Sonarr.exe", "--no-browser", "--data=/config"]
