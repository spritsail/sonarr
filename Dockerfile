FROM spritsail/alpine:3.21

# http://services.sonarr.tv/v1/releases
# https://services.sonarr.tv/v1/update/develop/changes?version=4&os=linux-musl
ARG SONARR_VER=4.0.15.2940
ARG SONARR_BRANCH=develop

ENV SUID=906 SGID=900

LABEL org.opencontainers.image.authors="Spritsail <sonarr@spritsail.io>" \
      org.opencontainers.image.title="Sonarr" \
      org.opencontainers.image.url="https://sonarr.tv/" \
      org.opencontainers.image.description="A TV show management and downloader tool" \
      org.opencontainers.image.version=${SONARR_VER} \
      io.spritsail.version.sonarr=${SONARR_VER}

WORKDIR /sonarr

COPY --chmod=755 *.sh /usr/local/bin/

RUN apk add --no-cache \
        icu-libs \
        sqlite-libs \
        xmlstarlet \
    \
 && test "$(uname -m)" = aarch64 && ARCH=arm64 || ARCH=x64 \
 && wget -O- "https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VER}/Sonarr.${SONARR_BRANCH}.${SONARR_VER}.linux-musl-${ARCH}.tar.gz" \
        | tar xz --strip-components=1 \
 && rm -rfv Sonarr.Update \
 && printf "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${SONARR_VER}" > package_info

VOLUME /config
ENV XDG_CONFIG_HOME=/config

EXPOSE 8989

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:8989/api/v3/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/sonarr/Sonarr", "--no-browser", "--data=/config"]
