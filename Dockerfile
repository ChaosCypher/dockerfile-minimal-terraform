ARG ALPINE_VERSION="3.13.5"

FROM alpine:${ALPINE_VERSION} AS stage1

ARG PLATFORM="linux_amd64"
ARG TERRAFORM_VERSION="0.15.4"

COPY hashicorp.asc hashicorp.asc

RUN apk add --no-cache gnupg \
    && gpg --import hashicorp.asc \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_${PLATFORM}.zip:\sOK" \
    && unzip terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
    && find /tmp -type f -type d -exec rm -rf {} +

FROM scratch as stage2

COPY --from=stage1 terraform /terraform
    # a /tmp directory is required by terraform
COPY --from=stage1 /tmp /tmp

FROM stage2

LABEL MAINTAINER="jamie@chaoscyper.ca"
LABEL TERRAFORM_VERSION=${TERRAFORM_VERSION}

ENTRYPOINT [ "/terraform" ]
