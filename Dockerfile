FROM debian:stretch
MAINTAINER Adam Dodman <adam.dodman@gmx.com>

ENV UID=906 GID=900

ARG TINI_VERSION=v0.14.0
ARG SU_EXEC_VER=v0.2

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
ADD https://github.com/javabean/su-exec/releases/download/v0.2/su-exec.amd64 /usr/bin/su-exec
ADD entrypoint.sh /usr/bin/entrypoint

RUN apt-get update \
 && apt-get install -y curl libmono-cil-dev mediainfo

RUN chmod +x /usr/bin/* \
 && sonarr_tag=$(curl -sX GET "https://api.github.com/repos/Sonarr/Sonarr/tags" | awk '/name/{print $4;exit}' FS='[""]') \
 && curl -L http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz | tar xz \
 && chmod -R 755 /NzbDrone/*


VOLUME ["/config", "/media"]

EXPOSE 8989

ENTRYPOINT ["/sbin/tini","--","/usr/bin/entrypoint"]
CMD ["mono","/NzbDrone/NzbDrone.exe","--no-browser","-data=/config"]
