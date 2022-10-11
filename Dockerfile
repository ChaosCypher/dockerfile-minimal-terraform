FROM alpine:3.16.2 AS stage1

ARG PLATFORM="linux_amd64"
ARG SCRATCH_USER="scratch"
ARG SCRATCH_USER_ID="1001"
ARG TERRAFORM_VERSION="1.3.2"

WORKDIR /

COPY hashicorp.asc hashicorp.asc
    # fail the Dockerfile build if any commands fail
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache ca-certificates==20220614-r0 \
                       gnupg==2.2.35-r4 \
        # expect a warning here because the trustdb is empty in this container - we manually verify the signature later
    && gpg --import hashicorp.asc \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.72D7468F.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
        # sha256sum packaged with alpine doesnt allow file exclusions so we need to isolate the file we want to verify
    && grep ${TERRAFORM_VERSION}_${PLATFORM}.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum \
    && unzip terraform_${TERRAFORM_VERSION}_${PLATFORM}.zip \
        # create a scratch user that will have an entry in the /etc/passwd file
    && addgroup -g ${SCRATCH_USER_ID} ${SCRATCH_USER} \
    && adduser --uid ${SCRATCH_USER_ID} \
               -G ${SCRATCH_USER} ${SCRATCH_USER} \
               --disabled-password \
    && find /tmp -type f -type d -exec rm -rf {} +

FROM scratch as stage2

COPY --from=stage1 terraform /terraform
    # a /tmp directory is required by terraform
COPY --from=stage1 /tmp /tmp
    # the terraform binary requires a ca bundle in order to interact with provider endpoints over tls
COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
    # copy the scratch user created in stage 1 to avoid running as root in the final image
COPY --from=stage1 /etc/passwd /etc/passwd

FROM stage2

LABEL minimal-terraform.apk-ca-cert-version="20220614-r0"
LABEL minimal-terraform.apk-gnupg-version="2.2.35-r4"
LABEL minimal-terraform.maintainer="jamie@chaoscypher.ca"
LABEL minimal-terraform.platform="linux_amd64"
LABEL minimal-terraform.terraform-version="${TERRAFORM_VERSION}"

# don't use the SCRATCH_USER Dockerfile arg as the azure/container-scan action doesn't handle this
USER scratch

HEALTHCHECK CMD terraform --version

ENTRYPOINT [ "/terraform" ]
