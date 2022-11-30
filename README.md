![Docker Pulls](https://img.shields.io/docker/pulls/qoopido/telerising.minimal.svg)

# telerising.minimal
A minimal docker container for running telerising 

### Prerequisites
You will need to have `docker` installed on your system and the user you want to run it needs to be in the `docker` group.

> **Note:** The image is a multi-arch build providing variants for amd64, arm32v7 and arm64v8 - the correct variant for your architecture should<sup>TM</sup> be pulled automatically.

### Initial setup

## Technical info for docker GUIs (e.g. Synology, UnRaid, OpenMediaVault)
To learn how to manually start the container or about available parameters (you might need for your GUI used) see the following example:

```
docker run \
  -d \
  -p 5000:5000 \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v {SETTINGS.JSON}:/settings.json \
  --user=${UID}:${GID} \
  --name=easyepg \
  --restart=unless-stopped \
  --network=bridge \
  qoopido/telerising.minimal:latest
```

Used volumes:

| Volume          | Optional | Description                                                                                                    |
|-----------------|----------|----------------------------------------------------------------------------------------------------------------|
| `SETTINGS.JSON` | no       | The path to your persisted Telerising configuration file (create a file containing just `{}` for new installs) |

When passing volumes please replace the name including the surrounding curly brackets with existing absolute paths with correct permissions.
