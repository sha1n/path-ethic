[![ci](https://github.com/sha1n/path-ethic/actions/workflows/ci.yml/badge.svg)](https://github.com/sha1n/path-ethic/actions/workflows/ci.yml)

- [path-ethic](#path-ethic)
  - [Commands](#commands)
    - [peth show](#peth-show)
    - [peth push \<path\>](#peth-push-path)
    - [peth append \<path\>](#peth-append-path)
    - [peth rm \<path\>](#peth-rm-path)
    - [peth reset](#peth-reset)
    - [peth commit](#peth-commit)
    - [peth reload](#peth-reload)
    - [peth update](#peth-update)
  - [How to Install](#how-to-install)
  - [How to Uninstall](#how-to-uninstall)
  - [Migrating Commited Data](#migrating-commited-data)

# path-ethic
`path-ethic` is simple [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) plugin that helps you manage your `PATH` quickly and easily. Being ethic and all, this plugin won't touch your existing `.zshrc`, `.zprofile` or `.bash_profile`, but add on top of your existing environment.


## Commands
### peth show
`peth show`   - displays the current value of `PATH` and the values of any set prefix and suffix.

```bash
peth show # or just peth
effective ➤ /Users/code/go/bin//Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin/Users/code/projects
   prefix ➤ /Users/code/go/bin/
   suffix ➤ /Users/code/projects
```

### peth push \<path\>
`peth push`   - adds a new element at the beginning of the `PATH` and re-exports.

### peth append \<path\>
`peth append` - adds a new element at the end of the `PATH` and re-exports.
 
### peth rm \<path\>
`peth rm` - removes a path element from the `PATH` and re-exports. If the removed element is a part of the normal user `PATH`, it is removed only in the current session even if the changes are committed.

### peth reset
`peth reset` - removes all prefixes and suffixes and re-exports the original `PATH`.

### peth commit 
`peth commit` - saves any `PATH` edits for later sessions. 

- Data is saved to `~/.path-ethic` 
- User home paths are substituted with `$HOME` for better portability

### peth reload
`peth reload` - reloads previously committed settings and discards any dirty state.

### peth update
`peth update` - if cloned from a remote git repository, prompts to pull the latest changes from that remote.


## How to Install
1. Clone this repository to `$ZSH_CUSTOM/plugins/path-ethic`
```bash
mkdir -p "$ZSH_CUSTOM" && git clone git@github.com:sha1n/path-ethics.git "$ZSH_CUSTOM/plugins/path-ethic"
```
2. Enable the plugin by adding `path-ethic` to the plugin list `plugins=()` in `~/.zshrc` .
```bash 
plugins=(
  path-ethic      # <-- add this
)
```

## How to Uninstall
1. Reverse the [installation steps](#how-to-install).
2. You may want to delete the file `~/.path-ethic`. This is where committed `PATH` elements are saved.

## Migrating Commited Data
In order to make committed changes more portable, when changes are saved all user home paths are replaced with `$HOME`. 
Therefore, when you migrate settings to a new machine or user, you can simply install the plugin, copy `path-ethic` dot file 
and you should be good to go.

**Steps:**
1. [Install the plugin](#how-to-install)
2. Copy `~/.path-ethic` to your other user home directory
