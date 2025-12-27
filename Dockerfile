FROM archlinux:base-devel AS python-base
ARG TZ=Asia/Vladivostok
ARG DOCKER_HOST_UID=10000
ARG DOCKER_HOST_GID=10000
ARG DOCKER_USER=devuser
ARG DOCKER_USER_HOME=/home/devuser
ARG MIRROR_LIST_COUNTRY=RU
ARG BUILD_PACKAGES="pyenv git gnupg sudo postgresql-libs mariadb-libs openmp"
ARG PYTHON_VERSION=3.14
ARG POETRY_VERSION=2.2.1
RUN echo "* soft core 0" >> /etc/security/limits.conf && \
    echo "* hard core 0" >> /etc/security/limits.conf && \
    echo "* soft nofile 10000" >> /etc/security/limits.conf
RUN sed -i 's/^UID_MAX.*/UID_MAX 999999999/' /etc/login.defs
RUN sed -i 's/^GID_MAX.*/GID_MAX 999999999/' /etc/login.defs
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN set -eux; \
	groupadd $DOCKER_USER --gid=$DOCKER_HOST_GID && \
	useradd --no-log-init -g $DOCKER_USER --uid=$DOCKER_HOST_UID \
  -d $DOCKER_USER_HOME -ms /bin/bash $DOCKER_USER
RUN mkdir /application && chown $DOCKER_USER:$DOCKER_USER /application
RUN set -eux; \
  curl -fsSL "https://archlinux.org/mirrorlist/?country=${MIRROR_LIST_COUNTRY}&protocol=http&protocol=https&ip_version=4" \
  | sed -e 's/^\s*#Server/Server/' -e '/^\s*#/d' \
  > /etc/pacman.d/mirrorlist; \
  grep -q '^Server' /etc/pacman.d/mirrorlist
RUN pacman -Syu --noconfirm && pacman -S --noconfirm --needed $BUILD_PACKAGES
RUN echo "${DOCKER_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ENV PYENV_ROOT=$DOCKER_USER_HOME/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install --skip-existing $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
RUN pyenv rehash
ENV PYTHONUNBUFFERED=1
ENV PIP_DEFAULT_TIMEOUT=100
ENV POETRY_NO_INTERACTION=1
ENV POETRY_HOME=/opt/poetry
ENV POETRY_CACHE_DIR=/var/cache/pypoetry
ENV PIP_CACHE_DIR=/var/cache/pip
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv --copies $VIRTUAL_ENV
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN pip install --upgrade pip
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION python -
ENV PATH=$POETRY_HOME/bin:$PATH
ENV PYTHONPATH=/application/src
ENV PROJECT_ROOT=/application

FROM python-base AS poetry
ARG DOCKER_USER=devuser
RUN mkdir -p $POETRY_CACHE_DIR && \
  chown -R $DOCKER_USER $POETRY_CACHE_DIR
RUN mkdir -p $PIP_CACHE_DIR && \
  chown -R $DOCKER_USER $PIP_CACHE_DIR
USER $DOCKER_USER
WORKDIR /application

FROM python-base AS app-build
ARG DOCKER_USER=devuser
COPY src/ build/src
COPY README.md /build/
COPY pyproject.toml poetry.lock /build/
ARG POETRY_OPTIONS_APP="--only main --compile"
RUN poetry install $POETRY_OPTIONS_APP -n -v -C /build && \
  rm -rf $POETRY_CACHE_DIR/* && rm -rf $PIP_CACHE_DIR/*
RUN sed -i "/\b\($DOCKER_USER\)\b/d" /etc/sudoers
RUN pacman -Scc --noconfirm
USER $DOCKER_USER
WORKDIR /application

FROM python-base AS build-deps-dev
ARG DOCKER_USER=devuser
ARG POETRY_OPTIONS_DEV="--no-root --with-dev --compile"
COPY pyproject.toml poetry.lock /build/
RUN poetry install $POETRY_OPTIONS_DEV -n -v -C /build 
RUN mkdir -p $POETRY_CACHE_DIR $PIP_CACHE_DIR && \
  chown -R $DOCKER_USER $POETRY_CACHE_DIR $PIP_CACHE_DIR

FROM build-deps-dev AS dev-build
ARG DOCKER_USER=devuser
USER $DOCKER_USER
WORKDIR /application

FROM build-deps-dev AS vim-ide
ARG DOCKER_USER=devuser
ARG DOCKER_USER_HOME=/home/devuser
ARG VIM_PACKAGES="python vim ctags ripgrep bat npm nodejs-lts-jod"
ARG NPM_GLOBAL_PACKAGES=""
RUN pacman -S --noconfirm --needed $VIM_PACKAGES
RUN if [ -n "$NPM_GLOBAL_PACKAGES" ]; then npm install -g --no-fund --no-audit $NPM_GLOBAL_PACKAGES; fi
USER $DOCKER_USER
RUN curl -fLo $DOCKER_USER_HOME/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN curl -fLo $DOCKER_USER_HOME/.vim/spell/en.utf-8.spl \
  --create-dirs https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.spl
RUN curl -fLo $DOCKER_USER_HOME/.vim/spell/en.utf-8.sug \
  --create-dirs https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.sug
RUN curl -fLo $DOCKER_USER_HOME/.vim/spell/ru.utf-8.spl \
  --create-dirs https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.spl
RUN curl -fLo $DOCKER_USER_HOME/.vim/spell/ru.utf-8.sug \
  --create-dirs https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.sug
COPY --chown=$DOCKER_USER:$DOCKER_USER .vimrc $DOCKER_USER_HOME/.vimrc
RUN cat $DOCKER_USER_HOME/.vimrc \
  |sed -n '/plug#begin/,/plug#end/p' > $DOCKER_USER_HOME/.vimrc_plug
RUN vim -u $DOCKER_USER_HOME/.vimrc_plug +'PlugInstall --sync' +qa
RUN vim -u $DOCKER_USER_HOME/.vimrc_plug \
  +'CocInstall -sync coc-pyright coc-json coc-yaml coc-snippets coc-markdownlint' +qa
COPY --chown=$DOCKER_USER:$DOCKER_USER .coc-settings.json \
  $DOCKER_USER_HOME/.vim/coc-settings.json
RUN git config --global --add safe.directory /application
ENV TERM=xterm-256color
WORKDIR /application
