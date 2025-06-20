FROM archlinux:base-devel AS python-base
ARG TZ=Asia/Vladivostok
ARG DOCKER_HOST_UID=10000
ARG DOCKER_HOST_GID=10000
ARG DOCKER_USER=devuser
ARG DOCKER_USER_HOME=/home/devuser
ARG MIRROR_LIST_COUNTRY=RU
ARG BUILD_PACKAGES="pyenv git gnupg sudo postgresql-libs mariadb-libs openmp"
ARG PYTHON_VERSION=3.13
ARG POETRY_VERSION=1.8.5
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
RUN curl -s \
  "https://archlinux.org/mirrorlist/?country=$MIRROR_LIST_COUNTRY&protocol=http&protocol=https&ip_version=4" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm $BUILD_PACKAGES
RUN echo "${DOCKER_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ENV PYENV_ROOT=$DOCKER_USER_HOME/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install $PYTHON_VERSION
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
RUN curl -sSL https://install.python-poetry.org | python -
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

FROM python-base AS build-deps
ARG POETRY_OPTIONS="--no-root --compile"
COPY pyproject.toml poetry.lock /build/
RUN poetry install $POETRY_OPTIONS -n -v -C /build && \
  rm -rf $POETRY_CACHE_DIR/* && rm -rf $PIP_CACHE_DIR/*

FROM build-deps AS app-build
ARG DOCKER_USER=devuser
COPY src/ build/src
COPY README.md /build/
RUN poetry install -C /build
RUN sed -i "/\b\($DOCKER_USER\)\b/d" /etc/sudoers
RUN pacman -Scc <<< Y <<< Y
USER $DOCKER_USER
WORKDIR /application

FROM build-deps AS vim-ide
ARG DOCKER_USER=devuser
ARG DOCKER_USER_HOME=/home/devuser
ARG VIM_PACKAGES="python vim ctags ripgrep bat npm nodejs-lts-jod"
RUN pacman -Sy && pacman -S --noconfirm $VIM_PACKAGES
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
