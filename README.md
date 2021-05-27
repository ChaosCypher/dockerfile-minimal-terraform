# dockerfile-minimal-terraform ![main branch](https://github.com/ChaosCypher/dockerfile-minimal-terraform/actions/workflows/docker-publish.yml/badge.svg?branch=main)
This repository aims to create a secure, customizable, minimal docker container that exposes the `terraform` binary to a host machine. It begins as an alpine base(`stage 1`), where gpg and sha validations occur. Following `stage 1` the terraform binary is copied from `stage 1` into a scratch base(`stage 2`).

Only **80.9MB**!!

## building the image

This snippet builds the container with default ARGS set in the Dockerfile:

```
docker build -t terraform:0.0.1 .
```

The defaults can be overwritten:

```
docker build --build-arg TERRAFORM_VERSION=0.14.1 -t terraform:0.0.1 .
```

## bundled package sizes

|Package         |Size  |
---------------- | ------
|ca-certificates |1.3MB |
|terraform       |79.6MB|


### Default Versions

|Docker Argument         |Default    |
------------------------ | -----------
|ALPINE_VERSION          |3.13.5     |
|PLATFORM                |linux_amd64|
|TERRAFORM_VERSION       |0.15.4     |
