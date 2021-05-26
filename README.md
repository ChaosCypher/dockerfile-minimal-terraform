# dockerfile-minimal-terraform
This repository aims to create a secure, minimal docker container that exposes the `terraform` binary to a host machine. It begins as an alpine base(`stage 1`), where gpg and sha validations occur. Following `stage 1` the terraform binary is copied from `stage 1` into a scratch base(`stage 2`).

## building the image

This snippet builds the container with default ARGS set in the Dockerfile:

```
docker build -t terraform:0.0.1 .
```

The defaults can be overwritten:

```
docker build --build-arg TERRAFORM_VERSION=0.14.1 -t terraform:0.0.1 .
```

### Default Versions

TO-DO
