FROM spritsail/mono:4.5

ARG SONARR_VER=2.0.0.5228

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

RUN apk add --no-cache sqlite-libs libmediainfo-patched xmlstarlet \
 && wget -O- "http://download.sonarr.tv/v2/master/mono/NzbDrone.master.${SONARR_VER}.mono.tar.gz" \
        | tar xz --strip-components=1 \
 && find -type f -exec chmod 644 {} + \
 && find -type d -o -name '*.exe' -exec chmod 755 {} + \
 && find -name '*.mdb' -delete \
# Where we're going, we don't need ~roads~ updates!
 && rm -rf NzbDrone.Update \
 && chmod +x /usr/local/bin/*.sh

VOLUME ["/config", "/media"]
ENV XDG_CONFIG_HOME=/config

EXPOSE 8989

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/sonarr/NzbDrone.exe", "--no-browser", "--data=/config"]
