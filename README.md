# dockerfile-minimal-terraform ![docker publish](https://github.com/ChaosCypher/dockerfile-minimal-terraform/actions/workflows/release.yaml/badge.svg)

This repository aims to create a secure, customizable, minimal Docker container that exposes the `terraform` binary to a host machine. It begins as an alpine base(`stage 1`), where gpg and sha validations occur. Following `stage 1` the terraform binary is copied from `stage 1` into a scratch base(`stage 2`).

Only **84.6MB**!!

## using the container

```shell
docker run --rm -it -v $PWD:$PWD -v /tmp:/tmp -w $PWD chaoscypher/minimal-terraform <COMMAND>
```

## building the image

This snippet builds the container with default ARGS set in the Dockerfile:

```shell
docker build -t terraform:main .
```

The defaults can be overwritten:

```shell
docker build --build-arg TERRAFORM_VERSION=1.4.6 -t terraform:main .
```
## Default Versions

| Docker Argument   | Default                              |
| ----------------- | ------------------------------------ |
| ALPINE_VERSION    | 3.23.0                               |
| PLATFORM          | linux\_${TARGETARCH} (auto-detected) |
| TERRAFORM_VERSION | 1.14.2                               |
