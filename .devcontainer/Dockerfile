# syntax=docker/dockerfile:1.8
# check=error=true

## Multi-stage build!
# Pull latest prebuilt Echidna binary.
# TODO: "Ensure the base image uses a non latest version tag"
FROM --platform=linux/amd64 ghcr.io/crytic/echidna/echidna:latest AS echidna

# Grab at least python 3.12
FROM python:3.12-slim AS python-base

# Base ubuntu build (latest).
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Switch to root (the default might be root anyway)
USER root

COPY --from=python-base /usr/local /usr/local

# Super basic stuff to get everything started
RUN apt-get update -y && apt-get install -y \
    python3-dev libpython3-dev build-essential vim curl git sudo pkg-config \
    --no-install-recommends

# The base container usually has a “vscode” user. If not, create one here.
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to vscode (drop privs)
USER vscode
WORKDIR /home/vscode
ENV HOME=/home/vscode

# Set neded paths (for python, pix, pnpm)
ENV USR_LOCAL_BIN=/usr/local/bin
ENV LOCAL_BIN=${HOME}/.local/bin
ENV PNPM_HOME=${HOME}/.local/share/pnpm
ENV PATH=${PATH}:${USR_LOCAL_BIN}:${LOCAL_BIN}:${PNPM_HOME}

# Install uv
RUN python3 -m pip install --no-cache-dir --upgrade uv

ENV SHELL=/usr/bin/bash
SHELL ["/usr/bin/bash", "-ic"]

USER root
## Install nvm, yarn, npm, pnpm
RUN curl -o- https://raw.githubusercontent.com/devcontainers/features/main/src/node/install.sh | bash
RUN chown -R vscode:vscode ${HOME}/.npm
USER vscode

RUN pnpm install hardhat -g

# Python installations
# Install slither, crytic-compile, solc, vyper, panoramix, slider-lsp (needed for contract explorer).
RUN uv tool install slither-analyzer && \ 
    uv tool install crytic-compile && \ 
    uv tool install vyper && \ 
    uv tool install slither-lsp && \ 
    uv tool install semgrep && \ 
    uv tool install slitherin && \ 
    uv tool install solc-select && \
    solc-select install 0.4.26 0.5.17 0.6.12 0.7.6 0.8.10 latest && solc-select use latest

# Fetch and install setups
## ityfuzz
RUN curl -fsSL https://ity.fuzz.land/ | bash
RUN ityfuzzup

## Foundry framework
RUN curl -fsSL https://foundry.paradigm.xyz | bash
RUN foundryup

## Aderyn
RUN curl -fsSL https://raw.githubusercontent.com/Cyfrin/up/main/install | bash
RUN cyfrinup

## Halmos
### First installs uv, and then the latest version of halmos and adds it to PATH
RUN curl -fsSL https://astral.sh/uv/install.sh | bash && \
    uv tool install halmos

# Copy prebuilt Echidna binary
COPY --chown=vscode:vscode --from=echidna /usr/local/bin/echidna ${HOME}/.local/bin/echidna
RUN chmod 755 ${HOME}/.local/bin/echidna

# Back to home in case we want to do something later.
WORKDIR ${HOME}


## Add completions for anvil, cast, forge.
RUN mkdir -p ${HOME}/.local/share/bash-completion/completions && \
    forge completions bash > ${HOME}/.local/share/bash-completion/completions/forge && \
    cast completions bash > ${HOME}/.local/share/bash-completion/completions/cast && \
    anvil completions bash > ${HOME}/.local/share/bash-completion/completions/anvil

USER root

## Clean
RUN apt-get autoremove -y && apt-get clean -y

## back to user!
USER vscode

# Example HEALTHCHECK, we don't need once since we're not using services. If you add services in the future, you would need to add "something" like this:
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD \
  bash -c 'command -v echidna && command -v slither && command -v solc && echo "OK" || exit 1'
