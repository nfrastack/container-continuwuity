# nfrastack/container-continuwuity

## About

This repository will build a container for [Continuwuity](https://github.com/continuwuity/continuwuity). A Matrix homeserver written in Rust, the official continuation of the conduwuit homeserver.

## Maintainer

- [Nfrastack](https://www.nfrastack.com)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
- [Users and Groups](#users-and-groups)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [License](#license)

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-continuwuity/pkgs/container/container-continuwuity) and [Docker Hub](https://hub.docker.com/r/nfrastack/continuwuity).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-continuwuity:(image_tag)
docker.io/nfrastack/continuwuity:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>-<optional_distribution>_<optional_distribution_variant>`

Example:

`ghcr.io/nfrastack/container-continuwuity:latest` or

`ghcr.io/nfrastack/container-continuwuity:1.0` or optionally

`ghcr.io/nfrastack/container-continuwuity:1.0-alpine` or optionally

`ghcr.io/nfrastack/container-continuwuity:alpine`

- `latest` will be the most recent commit
- An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
- If it is built for multiple distributions there may exist a value of `alpine` or `debian`
- If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

- The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

- Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
- Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory   | Description |
| ----------- | ----------- |
| `/config`   | Configuration |
| `/data`     | Database and media |
| `/logs`     | Logs |

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                         | Description |
| ------------------------------------------------------------- | ----------- |
| [OS Base](https://github.com/nfrastack/container-base/)       | Base Image  |
| [Nginx](https://github.com/nfrastack/container-nginx/)        | Nginx       |

Below is the complete list of available options that can be used to customize your installation.

- Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter          | Description                                                       | Default                | Advanced |
| ------------------ | ----------------------------------------------------------------- | ---------------------- | -------- |
| `SETUP_TYPE`       | Setup mode `AUTO` or `MANUAL`                                     | `AUTO`                 |          |
| `SERVER_NAME`      | Matrix server name (required, cannot be changed after init)       |                        |          |
| `DATA_PATH`        | Base data directory for database and media                        | `/data/`               |          |
| `CONFIG_PATH`      | Configuration directory                                           | `/config/`             |          |
| `CONFIG_FILE`      | Config filename                                                   | `conduwuit.toml`       |          |
| `LISTEN_PORT`      | Port for continuwuity to listen on                                | `8008`                 |          |
| `LISTEN_IP`        | IP for continuwuity to listen on                                  | `0.0.0.0`              |          |
| `ALLOW_REGISTRATION` | Allow user registration                                         | `false`                |          |
| `ALLOW_FEDERATION`   | Allow federation with other servers                              | `true`                 |          |
| `ALLOW_ENCRYPTION`   | Allow encrypted rooms and events                                 | `true`                 |          |
| `ALLOW_ROOM_CREATION` | Allow standard users to create rooms                            | `true`                 |          |
| `UPLOAD_MAX_SIZE`  | Max media upload size (Nginx-style format, e.g. `50M`, `1G`)    | `20M`                  |          |

All configuration is generated from environment variables prefixed with `CONTINUWUITY_*`. Each variable maps directly to a TOML config key. Use `__` (double underscore) for section nesting.

Three ways to set any config value (listed in precedence order):

| Method | Example | Description |
|--------|---------|-------------|
| `CONTINUWUITY_*` | `CONTINUWUITY_OAUTH__OIDC__CLIENT_SECRET=xxx` | Full prefix — always takes priority |
| Short section alias | `OAUTH__OIDC__CLIENT_SECRET=xxx` | Same as above, without the prefix. Any var containing `__` is auto-mapped |
| Short name alias | `OIDC_CLIENT_SECRET=xxx` | Convenience alias for common vars (see table below) |

**TOML section mapping examples:**

| Example Variable | Generated TOML |
|---|---|
| `CONTINUWUITY_OAUTH__OIDC__CLIENT_SECRET=nono` | `[oauth.oidc]` → `client_secret = "nono"` |
| `CONTINUWUITY_WELL_KNOWN__CLIENT=https://example.com` | `[global.well_known]` → `client = "https://..."` |
| `CONTINUWUITY_OAUTH__OIDC__ADDITIONAL_SCOPES=["profile", "email"]` | `[oauth.oidc]` → `additional_scopes = ["profile", "email"]` |

The `well_known` and `proxy` sections are automatically mapped under `[global]`.

##### OIDC / Well-Known Short Name Aliases

| Short Name | Maps to TOML |
|---|---|
| `OIDC_CLIENT_SECRET` | `[oauth.oidc]` → `client_secret` |
| `OIDC_DISCOVERY_URL` | `[oauth.oidc]` → `discovery_url` |
| `OIDC_CLIENT_ID` | `[oauth.oidc]` → `client_id` |
| `OIDC_ADDITIONAL_SCOPES` | `[oauth.oidc]` → `additional_scopes` |
| `OIDC_PROMPT_FOR_LOCALPART` | `[oauth.oidc]` → `prompt_for_localpart` |
| `OIDC_AUTOLOGIN` | `[oauth.oidc]` → `autologin` |
| `OIDC_PREFERRED_USERNAME_CLAIM` | `[oauth.oidc]` → `preferred_username_claim` |
| `WELL_KNOWN_CLIENT` | `[global.well_known]` → `client` |
| `WELL_KNOWN_SERVER` | `[global.well_known]` → `server` |

#### Log Configuration

| Parameter   | Description                                                  | Default                 | Advanced | TOML Key |
| ----------- | ------------------------------------------------------------ | ----------------------- | -------- | -------- |
| `LOG_TYPE`  | Log output type `console` `file` `both` `none`               | `both`                  |          | — |
| `LOG_LEVEL` | Log level (`trace`, `debug`, `info`, `warn`, `error`, `off`) | `info`                  |          | `log` |
| `LOG_PATH`  | Logfiles path                                                | `/logs/continuwuity/`   |          | — |
| `LOG_FILE`  | Logfile name                                                 | `continuwuity.log`      |          | — |

## Users and Groups

| Type  | Name           | ID   |
| ----- | -------------- | ---- |
| User  | `matrix` | 8008 |
| Group | `matrix` | 8008 |

### Networking

| Port   | Protocol | Description           |
| ------ | -------- | --------------------- |
| `8008` | tcp      | continuwuity daemon   |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

- For community help, tips, and community discussions, visit the [Discussions board](/discussions).
- For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
- To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
- Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
- Updates are best-effort, with priority given to active production use and support agreements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
