# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Copyright (c) Yoshinobu Ogura (Josh Nobus / @wsuzume).
# Distributed under the terms of the Modified BSD License.

# Ubuntu 22.04 (jammy)
# https://hub.docker.com/_/ubuntu/tags?page=1&name=jammy
ARG ROOT_CONTAINER=ubuntu:22.04

FROM $ROOT_CONTAINER

ARG USER="morgan"
ARG UID="1000"
ARG GID="100"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for the Server that starts
# but lacks all features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes \
    # - `apt-get upgrade` is run to patch known vulnerabilities in system packages
    #   as the Ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    && apt-get upgrade --yes

# Install fundamental tools
RUN apt-get install --yes --no-install-recommends \
    locales \
    sudo \
    # - `tini` is installed as a helpful container entrypoint,
    #   that reaps zombie processes and such of the actual executable we want to start
    #   See https://github.com/krallin/tini#why-tini for details
    tini

# You can install additional tools here
RUN apt-get install --yes --no-install-recommends \
    vim wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "C.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen

# Configure environment
ENV SHELL=/bin/bash \
    USER="${USER}" \
    UID=${UID} \
    GID=${GID} \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8
ENV HOME="/home/${USER}"

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create USER with name morgan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd --no-log-init --create-home --shell /bin/bash --uid "${UID}" --no-user-group "${USER}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "/home/${USER}"

USER ${UID}

# Setup work directory for backward-compatibility
RUN mkdir "/home/${USER}/work" && \
    fix-permissions "/home/${USER}"

# Copy local files as late as possible to avoid cache busting
COPY run-hooks.sh start.sh /usr/local/bin/

# Configure container entrypoint
ENTRYPOINT ["tini", "-g", "--", "start.sh"]

USER root

# Create dirs for startup hooks
RUN mkdir /usr/local/bin/start.d && \
    mkdir /usr/local/bin/init.d

# Switch back to jovyan to avoid accidental container runs as root
USER ${UID}

WORKDIR "${HOME}"