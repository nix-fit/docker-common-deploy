FROM nix-docker.registry.twcstorage.ru/base/redhat/ubi9-minimal:9.6@sha256:bb31756af74ea8e4ad046a80479e5aeea35fd01307a12d3ab9a5d92e8422b1f8

# Install prerequisites, git, python, pip, ansible
WORKDIR /etc/tools

RUN microdnf -y --refresh \
                --setopt=install_weak_deps=0 \
                --setopt=tsflags=nodocs install openssl \
                                                git \
                                                tar \
                                                gzip \
                                                python3.12 \
                                                python3.12-pip \
    && microdnf -y clean all \
    && rm -rf /var/cache/dnf /var/cache/yum \
    && git --version \
    && python3.12 --version \
    && python3.12 -m pip --version

COPY requirements.txt .

RUN python3.12 -m pip install --no-cache-dir -r requirements.txt \
    && ansible --version

# Install helm
ARG HELM_VERSION=3.19.0-linux-amd64
RUN curl -kLso helm-v${HELM_VERSION}.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}.tar.gz" \
    && tar -zxvf helm-v${HELM_VERSION}.tar.gz \
    && install -o root -g root -m 0755 linux-amd64/helm /usr/local/bin/helm \
    && helm version

# Install kubectl
ARG KUBECTL_VERSION=1.34.0
RUN curl -kLso kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && kubectl version --client --output=yaml \
    && rm -rf /etc/tools

ENV HELM_DRIVER=configmap \ 
    PYTHONWARNINGS=ignore

USER 10001

CMD ["/bin/sh"]
