# vim-python-docker-template

![image](https://github.com/user-attachments/assets/2846d6df-16de-4c24-b308-abb8534bd844)

<!-- vim-markdown-toc GFM -->

* [🧰 About the Template](#-about-the-template)
* [✅ Features](#-features)
* [🧪 Tested with](#-tested-with)
* [🚀 Getting Started](#-getting-started)
* [🧠 Vim IDE Features](#-vim-ide-features)
    * [🔌Included Plugins](#included-plugins)
    * [🗂 Additional Notes](#-additional-notes)

<!-- vim-markdown-toc -->

## 🧰 About the Template

**vim-python-docker-template** is a lightweight, flexible starting point for
containerized Python development. It’s especially well-suited for data science
and machine learning workflows that require OS-level packages,
hardware-specific dependencies, or reproducible environments.

This template allows you to write and run code inside the same containerized
environment using **Vim configured as a full-featured IDE** — making it ideal
for both local and remote development.

Whether you're scripting pipelines, prototyping machine learning models, or
building production tools, this setup provides a consistent, customizable
workflow with Vim at the center.

> ✨ Designed to work with *any* Python project — just plug in your code and
> dependencies.

The configuration is intentionally minimal and easy to adapt. You’re free to:
- Add or update Python dependencies
- Swap in different OS packages
- Customize the Vim environment
- Change Python or Poetry versions

Use it as-is or tailor it to match your team's development workflow.

## ✅ Features

- 📦 **Reproducible environments** for Python development
- 🛠 **IDE-like Vim setup**, ready to go out of the box
- 🐍 Supports custom **Python and Poetry** versions
- 🧩 Simple to extend with Jupyter, SQL drivers, and more
- 🔁 Works identically on any machine with Docker

## 🧪 Tested with

- **Docker**: `27.3.1` – `29.1.1`
- **buildx**: `0.20.0` – `0.30.0`
- **Compose**: `2.32.1` – `2.40.3`

## 🚀 Getting Started

1. Configure environment and Python settings

```bash
cp .env.dist .env
vim .env  # Set OS packages, Python version, Poetry version, etc.
```

2. Set up Python project dependencies

```bash
vim pyproject.toml  # Edit dependencies, metadata, etc.
docker compose build poetry
docker compose run --rm poetry lock  # Generate or update poetry.lock
# git add poetry.lock
```

3. Build your Vim IDE image

```bash
cp .vimrc.dist .vimrc
cp .coc-settings.json.dist .coc-settings.json
git config --local user.name "Your Name"
git config --local user.email you@example.com
docker compose build vim-ide
```

4. Start developing inside the container

```bash
docker compose run --rm vim-ide
```

5. Update dependencies when needed

```bash
docker compose run --rm poetry lock
```

> 🔄 Note: If you've changed dependencies (e.g. updated pyproject.toml or
> poetry.lock), you must rebuild the Vim IDE image to apply them:

```bash
docker compose build vim-ide
docker compose run --rm vim-ide
```

6. Build and run your application

```bash
docker compose build app
docker compose run --rm app
```

📓 Optional: Run JupyterLab

```bash
docker compose build jupyterlab
docker compose run --rm --service-ports jupyterlab
# Open: http://127.0.0.1:8888/lab?token=<your .env token>
```

## 🧠 Vim IDE Features

This template comes with a thoughtfully configured Vim environment that
replicates many features you'd expect from a modern IDE. It’s built for
productivity and designed to work out of the box — but is fully customizable.

✨ Core Capabilities

- ✅ Syntax highlighting & intelligent folding
- ✅ Autocompletion and LSP features via `coc.nvim`
- ✅ Linting, formatting, and diagnostics
- ✅ Git integration and diff signs
- ✅ Markdown editing with ToC, folding, and preview support
- ✅ Snippets, code actions, and refactoring shortcuts
- ✅ Enhanced status line, file tree, and fuzzy finding
- ✅ Python-focused indentation, folding, and style enforcement

### 🔌Included Plugins

🧠 Code Intelligence

- [coc.nvim](https://github.com/neoclide/coc.nvim) – LSP engine with autocompletion, diagnostics, and more
- [coc-pyright](https://github.com/fannheyward/coc-pyright) – Python LSP support
- [ultisnips](https://github.com/SirVer/ultisnips) + [vim-snippets](https://github.com/honza/vim-snippets) – Powerful snippet expansion

📁 Navigation & UI

- [NERDTree](https://github.com/preservim/nerdtree) – File tree explorer
- [fzf.vim](https://github.com/junegunn/fzf.vim) – Fuzzy file and symbol search
- [tagbar](https://github.com/preservim/tagbar) – Code structure sidebar
- [vim-airline](https://github.com/vim-airline/vim-airline) – Status/tab line enhancement

🔄 Git Integration

- [vim-fugitive](https://github.com/tpope/vim-fugitive) – Git commands from within Vim
- [vim-gitgutter](https://github.com/airblade/vim-gitgutter) – Git diff signs in the gutter

📝 Markdown Support

- [vim-markdown](https://github.com/plasticboy/vim-markdown) – Markdown editing enhancements
- [vim-markdown-toc](https://github.com/mzlogin/vim-markdown-toc) – Auto-generated table of contents

📊 Data Science & Python Dev

- [vim-slime](https://github.com/jpalardy/vim-slime) – Send code to REPL or terminal
- [vim-doge](https://github.com/kkoomen/vim-doge) – Generate docstrings in Google/Numpy style

🎨 Theme & Aesthetics

- [gruvbox-material](https://github.com/sainnhe/gruvbox-material) – Color scheme (dark, high-contrast)
- Airline integrated with Gruvbox

⚙️ Python-Specific Tuning

- Smart indentation for Python, with 4-space formatting
- `textwidth` and `colorcolumn` set to PEP8 defaults
- Spellcheck enabled for English and Russian
- LSP-based completion, hover docs, jump-to-definition, code actions

### 🗂 Additional Notes

- To customize the LSP setup, see `.coc-settings.json`
- To update CoC extensions: `:CocUpdate`
- Snippets can be edited under `~/.vim/plugged/vim-snippets`
- Full configuration lives in `.vimrc.dist` — tweak freely

This is a template for python-based projects. Many DS/ML workflows require
hardware-specific platforms in detailed OS-level libraries and python
dependencies. In some cases, it is useful to perform code editing in the same
environment in which applications are run. This template can help vim users to
run vim-ide with the same project environment on a local or remote machine.
Please, feel free to massage everything in the template as you wish.

Vim is configured in a modern style and supports almost all ide-specific
features. Please see `.vimrc.dist` for reference.
