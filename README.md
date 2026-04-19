# vim-python-docker-template

<p align="center">
  <img width="49%" alt="2026-02-21-235742_hyprshot" src="https://github.com/user-attachments/assets/e127964e-bee6-4e04-b4f5-0ec868adde2c" />
  <img width="49%" alt="2026-02-21-235947_hyprshot" src="https://github.com/user-attachments/assets/736614c3-0de0-4980-b828-6c938b4ae084" />
</p>

<!-- vim-markdown-toc GFM -->

* [About the Template](#about-the-template)
* [Features](#features)
* [Who Is This For?](#who-is-this-for)
* [Project Structure](#project-structure)
* [Tested with](#tested-with)
* [Prerequisites](#prerequisites)
* [Quickstart](#quickstart)
* [Example Project Templates](#example-project-templates)
  * [1. Data Science / ML Project](#1-data-science--ml-project)
  * [2. Backend API / Service Project](#2-backend-api--service-project)
* [🚀 Getting Started](#-getting-started)
  * [1. Configure environment and Python settings and API tokens](#1-configure-environment-and-python-settings-and-api-tokens)
  * [2. Set up Python project dependencies](#2-set-up-python-project-dependencies)
  * [3. Build your Vim IDE image](#3-build-your-vim-ide-image)
  * [4. Start developing inside the container](#4-start-developing-inside-the-container)
  * [5. Update dependencies when needed](#5-update-dependencies-when-needed)
  * [Build and run your application](#build-and-run-your-application)
  * [Optional: Use `dev` for checks and experiments](#optional-use-dev-for-checks-and-experiments)
  * [GitHub CI checks](#github-ci-checks)
  * [Optional: Run Codex or Gemini (see more examples below)](#optional-run-codex-or-gemini-see-more-examples-below)
  * [Optional: Run code-server (VS Code in browser)](#optional-run-code-server-vs-code-in-browser)
  * [Optional: Run JupyterLab](#optional-run-jupyterlab)
* [💻 AI-Powered CLI Workflow (Gemini & Codex)](#-ai-powered-cli-workflow-gemini--codex)
  * [If you do not have API keys](#if-you-do-not-have-api-keys)
  * [Where to run commands](#where-to-run-commands)
  * [Gemini CLI examples](#gemini-cli-examples)
  * [Codex CLI examples](#codex-cli-examples)
* [🔒 Security notes](#-security-notes)
* [🧠 Vim IDE Features](#-vim-ide-features)
  * [🔌Included Plugins](#included-plugins)
  * [🗂 Additional Notes](#-additional-notes)

<!-- vim-markdown-toc -->

## About the Template

**vim-python-docker-template** is a lightweight, flexible starting point for
containerized Python development where the only required host dependency is
Docker.

This template allows you to write and run code inside the same containerized
environment using either:

* **Vim configured as a full-featured IDE** (`vim-ide`)
* **VS Code in browser via code-server** (`code-server`)

Whether you're scripting pipelines, prototyping machine learning models, or
building production tools, this setup provides a consistent and reproducible
workflow for build, lint, test, and run operations through `docker compose`
commands.

> ✨ Designed to work with *any* Python project — just plug in your code and
> dependencies.

The configuration is intentionally minimal and easy to adapt. You’re free to:

* Add or update Python dependencies
* Swap in different OS packages
* Customize the Vim environment
* Change Python or Poetry versions

Use it as-is or tailor it to match your team's development workflow.

## Features

* **Docker-first workflow**: build, run, lint, and test inside containers
* **Single host dependency**: Docker Engine + Compose
* **Two editor paths**: `vim-ide` and `code-server` (VS Code in browser)
* **Built-in quality checks** with `ruff` and `pytest`
* **Reproducible Python environment** with customizable Python and Poetry
  versions
* **Optional tooling**: JupyterLab, Codex CLI, Gemini CLI
* **CI-ready template** with a simple GitHub Actions workflow

## Who Is This For?

* Teams that want Docker as the only required local dependency.
* Data science / ML projects that need notebooks, reproducible dependencies,
  and optional GPU/OS packages.
* Backend/API projects that need consistent lint/test/build behavior across
  machines.
* Developers who prefer either terminal-first editing (`vim-ide`) or
  browser-based VS Code (`code-server`).
* Repositories that need a simple CI baseline to extend over time.

## Project Structure

```text
.
├── .github/workflows/ci.yml      # GitHub CI: build dev/app, run Ruff + pytest
├── .vscode/*.json.dist           # VS Code / code-server editor defaults
├── src/sample/main.py            # Example application module
├── tests/sample/test_main.py     # Example pytest tests to extend in your project
├── Dockerfile                    # Multi-stage images (base, dev, vim-ide, code-server, app)
├── compose.yaml                  # Local service orchestration for template workflows
├── .env.dist                     # Default compose/build/runtime variables
├── pyproject.toml                # Poetry dependencies and tool configuration
├── poetry.lock                   # Locked dependency graph
└── README.md                     # Setup and usage documentation
```

This layout is intentionally minimal so it can be extended for any project.

## Tested with

* **Docker**: `27.3.1` – `29.2.1`
* **buildx**: `0.20.0` – `0.31.1`
* **Compose**: `2.32.1` – `5.0.2`

## Prerequisites

* Docker is the only required local runtime dependency.
* Docker Engine with `docker compose` v2.0+ (minimum). Tested versions are
  listed above.
* `docker buildx` is required only for cross-platform builds (when
  `DOCKER_PLATFORM` differs from your host). For native builds, it’s optional.
* A supported `DOCKER_PLATFORM` for your machine (for example, Apple Silicon
  users often set `DOCKER_PLATFORM=linux/arm64`)
* Note: the `codex-web-login` service uses `network_mode: host`. This works on
  Linux, and on macOS with recent Docker Desktop or OrbStack. If it doesn’t
  work in your setup, authenticate on the host (outside Docker) and use
  `OPENAI_API_KEY` / `GEMINI_API_KEY` inside the containers.

## Quickstart

```bash
cp .env.dist .env
cp .vimrc.dist .vimrc
cp .coc-settings.json.dist .coc-settings.json
docker compose build vim-ide
docker compose run --rm vim-ide

# Optional alternative editor:
# docker compose build code-server
# docker compose run --rm --service-ports code-server
# Open: http://127.0.0.1:${CODE_SERVER_PORT:-8443}
```

To exit Vim: `:q` (or `:qa` to quit all).

If you just want a shell in the dev environment:

```bash
docker compose build dev
docker compose run --rm dev
```

## Example Project Templates

### 1. Data Science / ML Project

Use this template when your project mixes notebooks, experiments, and Python
modules.

```text
.
├── src/<project_name>/...
├── notebooks/
├── data/
│   ├── raw/
│   └── processed/
├── tests/
├── pyproject.toml
└── README.md
```

Typical workflow:

```bash
docker compose build dev jupyterlab
docker compose run --rm --service-ports jupyterlab
docker compose run --rm dev ruff check .
docker compose run --rm dev pytest -q
```

### 2. Backend API / Service Project

Use this template when your project is mostly application code, tests, and CI
checks.

```text
.
├── src/<service_name>/
│   ├── api.py
│   ├── main.py
│   └── settings.py
├── tests/
├── pyproject.toml
└── README.md
```

Typical workflow: keep app code in `src/`, run `ruff` + `pytest` in `dev`, and
package runtime execution through the `app` service.

## 🚀 Getting Started

### 1. Configure environment and Python settings and API tokens

Set the `.env` values used by `compose.yaml` and the Docker build. Common ones:

* `TZ` — Container timezone (e.g. `Europe/Berlin`, `Asia/Vladivostok`).
* `DOCKER_PLATFORM` — Target architecture (e.g. `linux/amd64`, `linux/arm64`).
* `DOCKER_HOST_UID` / `DOCKER_HOST_GID` — Host user/group IDs for file
  ownership.
* `DOCKER_USER` / `DOCKER_USER_HOME` — Container user + home directory.
* `MIRROR_LIST_COUNTRY` — Arch mirror country code for pacman.
* `BUILD_PACKAGES` — System packages needed to build Python and runtime deps.
* `VIM_PACKAGES` — Extra tools installed in the dev/vim images.
* `PYTHON_VERSION` — Python version installed via pyenv.
* `POETRY_VERSION` — Poetry version installed in the image.
* `POETRY_OPTIONS_APP` — Poetry install flags for the app image.
* `POETRY_OPTIONS_DEV` — Poetry install flags for the dev image.
* `PIP_DEFAULT_TIMEOUT` — Pip network timeout (seconds).
* `JUPYTER_TOKEN` — Token for JupyterLab login.
* `CODE_SERVER_EXTENSIONS` — Space-separated extension IDs preinstalled in
  code-server.
* `CODE_SERVER_HOST` — Bind address for code-server (usually `0.0.0.0`).
* `CODE_SERVER_PORT` — Port for code-server.
* `CODE_SERVER_AUTH` — code-server auth mode (`password` or `none`).
* `CODE_SERVER_PASSWORD` — Password used by code-server when auth is
  `password`.
* `OPENAI_API_KEY` — API key for Codex.
* `GEMINI_API_KEY` — API key for Gemini.

Set `DOCKER_HOST_UID` / `DOCKER_HOST_GID` to match your host user so files
created in the container are editable on the host. On Unix-like systems, use
`id -u` and `id -g` to get the correct values.

```bash
cp .env.dist .env
vim .env
```

### 2. Set up Python project dependencies

```bash
vim pyproject.toml  # Edit dependencies, metadata, etc.
docker compose build poetry
docker compose run --rm poetry lock  # Generate or update poetry.lock
# git add poetry.lock
```

### 3. Build your Vim IDE image

```bash
cp .vimrc.dist .vimrc
cp .coc-settings.json.dist .coc-settings.json
git config --local user.name "Your Name"
git config --local user.email you@example.com
docker compose build vim-ide
```

### 4. Start developing inside the container

```bash
docker compose run --rm vim-ide
```

### 5. Update dependencies when needed

```bash
docker compose run --rm poetry lock
```

> 🔄 Note: If you've changed dependencies (e.g. updated pyproject.toml or
> poetry.lock), rebuild the image(s) that install Python dependencies:
> `vim-ide`, `dev`, `codex`, `gemini`, `code-server`, `jupyterlab`, and/or
> `app` depending on what you run.

```bash
docker compose build vim-ide
docker compose run --rm vim-ide
```

### Build and run your application

```bash
docker compose build app
docker compose run --rm app
```

> ℹ️ `vim-ide`, `poetry`, `codex`, `gemini`, `jupyterlab`, and `dev` bind-mount
> your working directory into the container for live editing. `app` is a
> “packaged” image (it copies your sources), so code changes require rebuilding
> `app`.

### Optional: Use `dev` for checks and experiments

`dev` is a general-purpose image for running tools, scripts, and ad-hoc checks
inside the same environment as your Vim IDE.

`dev` and `vim-ide` are built from the same base stage, so they share the same
tooling and system packages.

```bash
docker compose build dev
docker compose run --rm dev
```

Examples (quality checks): run tests with pytest, then run Ruff lint and
format checks.

```bash
docker compose run --rm dev pytest -q
docker compose run --rm dev ruff check
docker compose run --rm dev ruff format --check
```

### GitHub CI checks

This template includes a minimal GitHub Actions workflow in
`.github/workflows/ci.yml` that:

* builds `dev`, `app`, `vim-ide`, `codex`, `gemini`, `jupyterlab`, and
  `code-server`
* checks `vim`, `codex`, `gemini`, `jupyter-lab`, and `code-server` binaries
* runs `ruff check .`
* runs `ruff format --check .`
* runs `pytest -q`

The same pattern can be easily extended for any other CI system.

If you’re running as the non-root user and want to try extra system packages
before baking them into the image, use `sudo`:

```bash
docker compose run --rm dev sudo pacman -S --noconfirm <package>
```

### Optional: Run Codex or Gemini (see more examples below)

> 🔄 Note: `codex` and `gemini` CLIs are installed during the image build via
> Arch packages (`openai-codex`, `gemini-cli`) configured in `VIM_PACKAGES`
> inside `.env`.
>
> `vim-ide` does not carry API keys or auth volumes, so run Codex/Gemini in a
> separate terminal via their own services.

```bash
docker compose build codex
docker compose run --rm codex
```

If Codex asks for a less restricted sandbox while already running inside this
container, rerun it with:

```bash
docker compose run --rm codex -s danger-full-access
```

Use this only when you want Codex to execute commands directly inside the
container instead of using its own internal sandbox.

```bash
docker compose build gemini
docker compose run --rm gemini
```

### Optional: Run code-server (VS Code in browser)

Create the editor config files from dist templates (recommended):

```bash
mkdir -p .vscode
cp .vscode/settings.json.dist .vscode/settings.json
cp .vscode/extensions.json.dist .vscode/extensions.json
```

```bash
docker compose build code-server
docker compose run --rm --service-ports code-server
# Open: http://127.0.0.1:${CODE_SERVER_PORT}
```

`compose.yaml` controls port/auth via `CODE_SERVER_HOST`, `CODE_SERVER_PORT`,
`CODE_SERVER_AUTH`, and `CODE_SERVER_PASSWORD`.

### Optional: Run JupyterLab

```bash
docker compose build jupyterlab
docker compose run --rm --service-ports jupyterlab
# Open: http://127.0.0.1:8888/lab?token=<your .env token>
```

## 💻 AI-Powered CLI Workflow (Gemini & Codex)

This project template is designed to be easily integrated with powerful CLI
tools like Gemini and Codex, enhancing your development workflow with
intelligent assistance. Rather than replacing your editor, these tools
complement Vim by running alongside it in a separate terminal (via
`docker compose run`) so you can inspect, generate, and reason about code
without breaking flow.

NOTE: To use AI CLI tools such as Gemini or Codex, you must configure API keys
according to each provider’s official documentation.

### If you do not have API keys

API keys for Codex and Gemini require separate billing. In some cases, you can
use an OpenAI subscription (for example, ChatGPT Pro) or take advantage of the
available limits of a personal Google account.

This type of access requires authentication via a browser. Run these from a
separate terminal via the `codex` / `gemini` services (not `vim-ide`). For
OpenAI, run the command:

```bash
docker compose run --rm codex-web-login
```

For Gemini, there is no separate login command — just run:

```bash
docker compose run --rm gemini
```

and choose “Login with Google.”

After completion, the authorization file will be saved to
`${DOCKER_USER_HOME}/.codex` or `${DOCKER_USER_HOME}/.gemini`. In this
template, those directories are persisted between runs via the `codex-auth` and
`gemini-auth` Docker volumes, which allows the agent CLI tool to be restarted
without any additional authentication steps.

### Where to run commands

Run the CLIs in their own containers (recommended):

```bash
docker compose run --rm codex
docker compose run --rm gemini
```

`vim-ide` is for editing only; it does not mount the auth volumes or API keys.

### Gemini CLI examples

The Gemini CLI provides a conversational interface to interact with your
codebase, allowing you to ask questions, refactor code, fix bugs, and add new
features.

Run all Gemini commands via Docker Compose so auth volumes and API keys are
available:

```bash
docker compose run --rm gemini
```

Read a file:

```bash
docker compose run --rm gemini read src/sample/main.py
```

List directory contents:

```bash
docker compose run --rm gemini list src/sample
```

Explain a code snippet (hypothetical):

```bash
docker compose run --rm gemini explain "def my_function():" --file src/sample/main.py
```

### Codex CLI examples

The Codex CLI (or similar code generation/analysis tools) can be used for
automating code generation, understanding project structure, and suggesting
improvements.

Run all Codex commands via Docker Compose so auth volumes and API keys are
available:

```bash
docker compose run --rm codex
```

Generate a new Python class (hypothetical):

```bash
docker compose run --rm codex generate class User --fields name:str,email:str --language python --file src/models.py
```

Analyze dependencies (hypothetical):

```bash
docker compose run --rm codex analyze dependencies --project-root .
```

Suggest tests for a file (hypothetical):

```bash
docker compose run --rm codex suggest tests --file src/sample/main.py
```

## 🔒 Security notes

Never commit `.env` (it contains secrets like `OPENAI_API_KEY`,
`CODE_SERVER_PASSWORD`,
`GEMINI_API_KEY`, and `JUPYTER_TOKEN`).

If you need to share the resolved Compose config, use
`docker compose config --no-interpolate` to avoid printing secret values.

Browser-based auth persists under `${DOCKER_USER_HOME}/.codex` and
`${DOCKER_USER_HOME}/.gemini` via the `codex-auth` and `gemini-auth` Docker
volumes.

`codex -s danger-full-access` disables Codex's internal command sandbox. It
does not change Docker's seccomp profile and does not add Linux capabilities to
the container. In this mode, Codex gets the same access as the container
itself, including the bind-mounted `/application` workspace, available network
access, and the persisted auth volume under `${DOCKER_USER_HOME}/.codex`.

## 🧠 Vim IDE Features

This template comes with a thoughtfully configured Vim environment that
replicates many features you'd expect from a modern IDE. It’s built for
productivity and designed to work out of the box — but is fully customizable.

✨ Core Capabilities

* Syntax highlighting & intelligent folding
* Autocompletion and LSP features via `coc.nvim`
* Linting, formatting, and diagnostics
* Git integration and diff signs
* Markdown editing with ToC, folding, and preview support
* Snippets, code actions, and refactoring shortcuts
* Enhanced status line, file tree, and fuzzy finding
* Python-focused indentation, folding, and style enforcement

### 🔌Included Plugins

🧠 Code Intelligence

* [coc.nvim](https://github.com/neoclide/coc.nvim) – LSP engine with
  autocompletion, diagnostics, and more
* [coc-pyright](https://github.com/fannheyward/coc-pyright) – Python LSP
  support
* [ultisnips](https://github.com/SirVer/ultisnips) +
  [vim-snippets](https://github.com/honza/vim-snippets) – Powerful snippet
  expansion

📁 Navigation & UI

* [NERDTree](https://github.com/preservim/nerdtree) – File tree explorer
* [fzf.vim](https://github.com/junegunn/fzf.vim) – Fuzzy file and symbol search
* [tagbar](https://github.com/preservim/tagbar) – Code structure sidebar
* [vim-airline](https://github.com/vim-airline/vim-airline) – Status/tab line
  enhancement

🔄 Git Integration

* [vim-fugitive](https://github.com/tpope/vim-fugitive) – Git commands from
  within Vim
* [vim-gitgutter](https://github.com/airblade/vim-gitgutter) – Git diff signs
  in the gutter

📝 Markdown Support

* [vim-markdown](https://github.com/plasticboy/vim-markdown) – Markdown editing
  enhancements
* [vim-markdown-toc](https://github.com/mzlogin/vim-markdown-toc) –
  Auto-generated table of contents

📊 Data Science & Python Dev

* [vim-slime](https://github.com/jpalardy/vim-slime) – Send code to REPL or
  terminal
* [vim-doge](https://github.com/kkoomen/vim-doge) – Generate docstrings in
  Google/Numpy style

🎨 Theme & Aesthetics

* [gruvbox-material](https://github.com/sainnhe/gruvbox-material) – Color
  scheme (dark, high-contrast)
* Airline integrated with Gruvbox

⚙️ Python-Specific Tuning

* Smart indentation for Python, with 4-space formatting
* `textwidth` and `colorcolumn` set to PEP8 defaults
* Spellcheck enabled for English and Russian
* LSP-based completion, hover docs, jump-to-definition, code actions

### 🗂 Additional Notes

* To customize the LSP setup, see `.coc-settings.json`
* To update CoC extensions: `:CocUpdate`
* Snippets can be edited under `~/.vim/plugged/vim-snippets`
* Full configuration lives in `.vimrc.dist` — tweak freely
