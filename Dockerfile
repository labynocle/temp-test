ARG FROM_IMAGE=python
ARG FROM_TAG=3.11.5-bookworm

FROM ${FROM_IMAGE}:${FROM_TAG}

# This variable will be useful to check if you're in the docker container or not
ENV CONTEXT_DOCKER=True

# Just to enjoy a better prompt
ENV CONTAINER_NAME=botify-deployment
RUN echo 'export PS1="🐳 \e[0;93m${CONTAINER_NAME}\e[0m \w # "' >> /etc/bash.bashrc

# Install system requirements
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libsasl2-dev \
        python3-dev \
        libldap2-dev \
        libssl-dev \
        rsync

# Yq installation
ARG YQ_VERSION=v4.35.1
RUN wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
        -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Jq installation
ARG JQ_VERSION=1.6
RUN wget -q https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 \
        -O /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq

# Terraform installation
ARG TERRAFORM_VERSION=1.3.9
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
         -O /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /tmp/ \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm /tmp/terraform.zip

# Terragrunt installation
ARG TERRAGRUNT_VERSION=v0.35.3
RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
        -O /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# AWS cli installation
ARG AWS_CLI_VERSION=2.12.7
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" \
        -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf \
        awscliv2.zip \
        ./aws

# GCP cli installation
ARG GCLOUD_CLI_VERSION=445.0.0
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        google-cloud-cli=${GCLOUD_CLI_VERSION}-0 \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install Python requirements
ARG PYTHON_REQUIREMENTS_DOCKER_FILE=/tmp/requirements.txt
ARG PYTHON_REQUIREMENTS_LOCAL_FILE=ansible/requirements.txt
COPY ${PYTHON_REQUIREMENTS_LOCAL_FILE} ${PYTHON_REQUIREMENTS_DOCKER_FILE}
RUN pip install --upgrade pip setuptools \
    && pip install -r ${PYTHON_REQUIREMENTS_DOCKER_FILE} \
    && pip cache purge \
    && rm ${PYTHON_REQUIREMENTS_DOCKER_FILE}

