[hub]: https://hub.docker.com/r/spritsail/deluge
[git]: https://github.com/spritsail/deluge
[drone]: https://drone.spritsail.io/spritsail/deluge
[mbdg]: https://microbadger.com/images/spritsail/deluge

# [spritsail/Deluge][hub]

[![](https://images.microbadger.com/badges/image/spritsail/deluge.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/spritsail/deluge.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/spritsail/deluge.svg)][git]
[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/deluge.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/deluge.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/deluge/status.svg)][drone]


[Sonarr](https://github.com/Sonarr/Sonarr) running in Debian Linux. This container provides some simple initial configuration scripts to set some runtime variables (see [#Configuration](#configuration) for details)

## Usage

Basic usage with default configuration:
```bash
docker run -dt
    --name=sonarr
    --restart=always
    -v $PWD/config:/config
    -p 8989:8989
    spritsail/sonarr
```

**Note:** _Is is important to use `-t` (pseudo-tty) as without it there are no logs produced._

Advanced usage with custom configuration:
```bash
docker run -dt
    --name=sonarr
    --restart=always
    -v $PWD/config:/config
    -p 8989:8989
    -e URL_BASE=/sonarr
    -e ANALYTICS=false
    -e ...
    spritsail/sonarr
```

### Volumes

* `/config` - Sonarr configuration file and database storage. Should be readable and writeable by `$UID` 

Other files accessed by Sonarr such as tv-show directories should also be readable and writeable by `$UID` or `$GID` with sufficient permissions.

`$UID` defaults to 906

### Configuration

These configuration options set the respective options in `config.xml` and are provided as a Docker convenience.

* `LOG_LEVEL` - Options are:  `Trace`, `Debug`, `Info`. Default is `Info`
* `URL_BASE`  - Configurable by the user. Default is _empty_
* `BRANCH`    - Upstream tracking branch for updates. Options are: `master`, `develop`, _other_. Default is `develop`
* `ANALYTICS` - Truthy or falsy value `true`, `false` or similar. Default is `true`
