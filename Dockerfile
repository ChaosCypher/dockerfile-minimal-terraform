ARG ALPINE_VERSION="3.15.0"

FROM alpine:${ALPINE_VERSION} AS stage1

ARG CA_CERT_VERSION="20211220-r0"
ARG GNUPG_VERSION="2.2.31-r1"
ARG PLATFORM="linux_amd64"
ARG TERRAFORM_VERSION="1.1.4"

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
    && find /tmp -type f -type d -exec rm -rf {} +

FROM scratch as stage2

COPY --from=stage1 terraform /terraform
    # a /tmp directory is required by terraform
COPY --from=stage1 /tmp /tmp
    # the terraform binary requires a ca bundle in order to interact with provider endpoints over tls
COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

FROM stage2

LABEL minimal-terraform.apk-ca-cert-version="${CA_CERT_VERSION}"
LABEL minimal-terraform.apk-gnupg-version="${GNUPG_VERSION}"
LABEL minimal-terraform.maintainer="jamie@chaoscypher.ca"
LABEL minimal-terraform.platform="${PLATFORM}"
LABEL minimal-terraform.terraform-version="${TERRAFORM_VERSION}"

ENTRYPOINT [ "/terraform" ]
