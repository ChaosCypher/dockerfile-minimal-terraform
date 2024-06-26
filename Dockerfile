# syntax=docker/dockerfile:1.5

ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

FROM alpine:3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd AS stage1

ARG CA_CERT_VERSION="20240226-r0"
ARG GNUPG_VERSION="2.4.5-r0"
ARG PLATFORM="linux_arm64"
ARG TERRAFORM_VERSION="1.8.5"

WORKDIR /

COPY hashicorp.asc hashicorp.asc

# fail the Dockerfile build if any commands fail
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache ca-certificates==${CA_CERT_VERSION} \
                       gnupg==${GNUPG_VERSION} \
        # expect a warning here because the trustdb is empty in this container - we manually verify the signature later
    && gpg --import hashicorp.asc \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
        # sha256sum packaged with alpine doesnt allow file exclusions so we need to isolate the file we want to verify
    && grep ${TERRAFORM_VERSION}_${PLATFORM}.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum \
    && unzip terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
        # create an entry for /etc/passwd file in the next stage
    && echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd \
    && find /tmp -type f -type d -exec rm -rf {} +

FROM scratch as stage2

COPY --from=stage1 terraform /terraform
    # a /tmp directory is required by terraform
COPY --from=stage1 /tmp /tmp
    # the terraform binary requires a ca bundle in order to interact with provider endpoints over tls
COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
    # /etc/passwd is required to run as a non-root user in a scratch container
COPY --from=stage1 /etc_passwd /etc/passwd

FROM stage2

LABEL org.opencontainers.image.authors="jamie@chaoscypher.ca"
LABEL org.opencontainers.image.description="A minimal Terraform image"
LABEL org.opencontainers.image.source="https://github.com/ChaosCypher/dockerfile-minimal-terraform/blob/main/Dockerfile"

USER nobody

HEALTHCHECK CMD terraform --version

ENTRYPOINT [ "/terraform" ]
