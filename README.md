# dockerfile-minimal-terraform ![docker publish](https://github.com/ChaosCypher/dockerfile-minimal-terraform/actions/workflows/release.yaml/badge.svg)
This repository aims to create a secure, customizable, minimal docker container that exposes the `terraform` binary to a host machine. It begins as an alpine base(`stage 1`), where gpg and sha validations occur. Following `stage 1` the terraform binary is copied from `stage 1` into a scratch base(`stage 2`).

Only **64.87MB**!!

## using the container

```shell
docker run --rm -it -v $PWD:$PWD -w $PWD chaoscypher/minimal-terraform <COMMAND>
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

|Docker Argument         |Default    |
------------------------ | -----------
|ALPINE_VERSION          |3.18.0     |
|CA_CERT_VERSION         |20230506-r0|
|GNUPG_VERSION           |2.4.1-r1   |
|PLATFORM                |linux_amd64|
|TERRAFORM_VERSION       |1.5.1      |
