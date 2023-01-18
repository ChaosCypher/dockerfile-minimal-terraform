# dockerfile-minimal-terraform ![main branch](https://github.com/ChaosCypher/dockerfile-minimal-terraform/actions/workflows/docker-publish.yml/badge.svg?branch=main)
This repository aims to create a secure, customizable, minimal docker container that exposes the `terraform` binary to a host machine. It begins as an alpine base(`stage 1`), where gpg and sha validations occur. Following `stage 1` the terraform binary is copied from `stage 1` into a scratch base(`stage 2`).

Only **62.2MB**!!

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
docker build --build-arg TERRAFORM_VERSION=0.14.1 -t terraform:main .
```

## Default Versions

|Docker Argument         |Default    |
------------------------ | -----------
|ALPINE_VERSION          |3.17.1     |
|CA_CERT_VERSION         |20220614-r4|
|GNUPG_VERSION           |2.2.40-r0  |
|PLATFORM                |linux_amd64|
|TERRAFORM_VERSION       |1.3.7      |
