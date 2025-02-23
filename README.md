# vim-python-docker-template

![image](https://github.com/user-attachments/assets/2846d6df-16de-4c24-b308-abb8534bd844)

This is a template for python-based projects. Many DS/ML workflows require
hardware-specific platforms in detailed OS-level libraries and python
dependencies. In some cases, it is useful to perform code editing in the same
environment in which applications are run. This template can help vim users to
run vim-ide with the same project environment on a local or remote machine.
Please, feel free to massage everything in the template as you wish.

Vim is configured in a modern style and supports almost all ide-specific
features. Please see `.vimrc.dist` for reference.

Tested under versions:

- docker `27.3.1`
- buildx `2.32.1`
- compose `2.32.1`

## How to use template

First, initialize the compose env, pick the required OS packages, and set the
python/poetry versions:

```bash
cp .env.dist .env
vim .env
```

Edit the poetry configuration file to manage python project-specific things and
dependencies:

```bash
vim pyproject.toml
```

Build python base image with poetry layer and create a lock file:

```bash
docker compose build poetry
docker compose run --rm poetry lock --no-cache
git add poetry.lock
```

Second, create the image with python dependencies and vim-ide on top of it:

```bash
cp .vimrc.dist .vimrc
cp .coc-settings.json.dist .coc-settings.json
git config --local user.name "John Doe"
git config --local user.email johndoe@example.com
docker compose build vim-ide
```

Launch vim and do some development inside the container:

```bash
docker compose run --rm vim-ide
```

Don't forget to update the lock file:

```bash
docker compose run --rm poetry lock --no-cache
```

Finally, build and run your application:

```bash
docker compose build app
docker compose run --rm app
```

If desired, you can run Jupyter on top of the application:

```bash
docker compose build jupyterlab
docker compose run --rm --service-ports jupyterlab
# accsess http://127.0.0.1:8888/lab?token=<.env token>
```

