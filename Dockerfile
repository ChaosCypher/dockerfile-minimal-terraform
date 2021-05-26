ARG ALPINE_VERSION="3.13.5"

FROM alpine:${ALPINE_VERSION} AS INTEGRITYCHECK

ARG PLATFORM="linux_amd64"
ARG TERRAFORM_VERSION="0.15.4"

COPY hashicorp.asc /tmp/hashicorp.asc

RUN apk add --no-cache gnupg \
    && gpg --import /tmp/hashicorp.asc \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget -q https://releases.hashicorp.com/terraform/0.15.4/terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_${PLATFORM}.zip:\sOK" \
    && unzip terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip -d /tmp

FROM scratch

LABEL MAINTAINER="jamie@chaoscyper.ca"
LABEL TERRAFORM_VERSION=${TERRAFORM_VERSION}

COPY --from=INTEGRITYCHECK /tmp/terraform /

ENTRYPOINT [ "/terraform" ]
