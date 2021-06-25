Change into the project directory.

```
$ [[ -e pyproject.toml ]] || cd $(basename -s .git "${GIT_REPO}")
```
