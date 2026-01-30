[![ci](https://github.com/sha1n/path-ethic/actions/workflows/ci.yml/badge.svg)](https://github.com/sha1n/path-ethic/actions/workflows/ci.yml)

- [PATH Ethic](#path-ethic)
  - [Main Features](#main-features)
  - [Limitations](#limitations)
  - [Alternatives](#alternatives)
- [Features](#features)
  - [Path Editing Commands](#path-editing-commands)
    - [show](#show)
    - [list](#list)
    - [push](#push)
    - [append](#append)
    - [flip](#flip)
    - [rm](#rm)
    - [reset](#reset)
  - [Preset Management Commands](#preset-management-commands)
    - [save](#save)
    - [load](#load)
    - [listp](#listp)
    - [rmp](#rmp)
  - [Other Commands](#other-commands)
    - [update](#update)
    - [help](#help)
  - [Automatic Preset Loading with `.pethrc`](#automatic-preset-loading-with-pethrc)
  - [Zsh Completion](#zsh-completion)
- [How to Install](#how-to-install)
  - [Install as Oh-My-Zsh plugin](#install-as-oh-my-zsh-plugin)
- [How to Uninstall](#how-to-uninstall)
- [Migrating Persistent Data](#migrating-persistent-data)


# PATH Ethic
`path-ethic` is a native `Zsh` plugin that provides CLI for `PATH` manipulation, preset management and automatic loading. It does not touch your existing `.zshrc`, `.zprofile` or any other shell environment configuration, but adds on top of your existing environment.

<img src="docs/images/presets-demo.gif" width="100%">

## Main Features
- quick and easy CLI based `PATH` management
- named `PATH` [presets](#preset-management-commands)
- [automatic](#automatic-preset-loading-with-pethrc) preset loading
- scripting friendly

## Limitations
- designed to work with Zsh only
- the default preset cannot completely override the shell `PATH`

## Alternatives
If you are looking for a more comprehensive and advanced shell environment configuration management tool, or something that supports more shells, check out [direnv](https://github.com/direnv/direnv).

# Features
## Path Editing Commands
### show
`peth [show]` - displays the current value of `PATH` and the values of any set prefix and suffix.

<img src="docs/images/peth-show.png" width="100%">

### list
`peth list` - similar to `show` but lists elements in separate lines.

<img src="docs/images/peth-list.png" width="100%">

### push
`peth push <path>` - adds a new element at the beginning of the `PATH` and re-exports.

### append
`peth append <path>` - adds a new element at the end of the `PATH` and re-exports.
 
### flip
`peth flip` - flips the prefix and suffix to reverse their priority. This is a very handy feature if often need to switch between different verisons of the same software.

<details>
  <summary>Demo</summary>
  <img src="docs/images/peth-flip-demo.gif" width="100%">
</details>

### rm
`peth rm <path>` - removes a path element from the `PATH` and re-exports.

### reset
`peth reset` - removes all prefixes and suffixes and re-exports the original `PATH`.

## Preset Management Commands
### save
`peth save [name]` - saves the current session `PATH` settings as a preset for later recall. If the optional name argument is provided, settings are saved as a named preset, otherwise 
they are saved to the default preset. The **default** preset is special in the fact that it does not include changes made to the original `PATH` during the session. Instead it only saves 
the prefix and suffix. This makes it possible to always go back to your current `.zshrc` or `.zprofile` set `PATH` settings and edit from there.

- Data is saved to `~/.path-ethic` 
- User home paths are substituted with `$HOME` for better portability

### load
`peth load [name]` - loads a previously saved preset into the current session. If the optional name argument is provided, attempts to load a named preset, otherwise loads the default
preset.

### listp
`peth listp` - lists all saved presets with a visual indication regarding which one is currently loaded.

### rmp
`peth rmp <name>` - removes a previously saved named preset (prompts for confirmation).

## Other Commands
### update
`peth update` - if cloned from a remote git repository, prompts to pull the latest changes from that remote.

### help
`peth help` - displays help.

## Automatic Preset Loading with `.pethrc`
When you change directory the plugin looks for a file named `.pethrc` in the target directory. If one is found, it tries to read a preset name from it and load it into the current session. This is helpful if you need different sets of tools or verisons for different projects. To take advantage of this feature, first [save](#save) a named preset and then just create a `.pethrc` with its name in your project directory.

## Zsh Completion
The plugin comes bundled with completion functions that are automatically registered to be loaded if Zsh completion system is enabled.
If completion doesn't work for the `peth` command, consider adding the following to `.zshrc`.

```bash
# enable autocomplete functions
autoload -U compinit
compinit
```

# How to Install
1. Clone this repository to a directory of your choice
```bash
cd /your-dir
git clone git@github.com:sha1n/path-ethic.git
```
2. Enable the plugin by sourcing it's main script in `~/.zshrc` .
```bash 
source /your-dir/path-ethic/path-ethic.plugin.zsh
```
## Install as Oh-My-Zsh plugin
1. Clone this repository to `$ZSH_CUSTOM/plugins/path-ethic`
```bash
mkdir -p "$ZSH_CUSTOM/plugins" && git clone git@github.com:sha1n/path-ethic.git "$ZSH_CUSTOM/plugins/path-ethic"
```
2. Enable the plugin by adding `path-ethic` to the plugin list `plugins=()` in `~/.zshrc` .
```bash 
plugins=(
  path-ethic      # <-- add this
)
```

# How to Uninstall
1. Reverse the [installation steps](#how-to-install).
2. You may want to delete the directory `~/.path-ethic`. This is where committed `PATH` elements and presets are saved.

# Migrating Persistent Data
In order to make committed changes more portable, right before changes are saved all user home paths are replaced with `$HOME`. 
Therefore, when you migrate settings to a new computer or user on the same computer, you can simply install the plugin, copy `~/.path-ethic` 
to your new home directory and you should be good to go.

