- [path-ethic](#path-ethic)
  - [Shell Commands](#shell-commands)
    - [peth show](#peth-show)
    - [peth push \<path\>](#peth-push-path)
    - [peth append \<path\>](#peth-append-path)
    - [peth rm \<path\>](#peth-rm-path)
    - [peth reset](#peth-reset)
    - [peth commit](#peth-commit)
  - [Installation](#installation)

# path-ethic
`path-ethic` is simple [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) plugin that helps you manage your `PATH` quickly and easily. Being ethic and all, this plugin won't touch your existing `.zshrc`, `.zprofile` or `.bash_profile`, but add on top of your existing environment.


## Shell Commands
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

```bash
peth push /Users/code/go/bin/
effective ➤ /Users/code/go/bin/:/Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
   prefix ➤ /Users/code/go/bin/
   suffix ➤
```

### peth append \<path\>
`peth append` - adds a new element at the end of the `PATH` and re-exports.
 
```bash
peth append /Users/code/projects
effective ➤ /Users/code/go/bin/:/Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/code/projects
   prefix ➤ /Users/code/go/bin/
   suffix ➤ /Users/code/projects
```

### peth rm \<path\>
`peth rm` - removes a path element from the `PATH` and re-exports. If the removed element is a part of the normal user `PATH`, it is removed only in the current session even if the changes are committed.
```bash
peth show
effective ➤ /Users/code/go/bin//Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin/Users/code/projects
   prefix ➤ /Users/code/go/bin/
   suffix ➤ /Users/code/projects

peth rm /Users/code/go/bin/
effective ➤ /Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/code/projects
   prefix ➤
   suffix ➤ /Users/code/projects

peth rm /Users/code/projects
effective ➤ /Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
   prefix ➤
   suffix ➤
```

### peth reset
`peth reset` - removes all prefixes and suffixes and re-exports the original `PATH`.

```bash
peth reset
effective ➤ /Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
   prefix ➤ 
   suffix ➤ 
```

### peth commit 
`peth commit` - saves any pushed or appended elements for later reload (saved to `~/.path-ethic`).

```bash
peth commit
effective ➤ /Users/code/go/bin/:/Users/code/.local/bin:/Users/code/.nvm/versions/node/v16.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/code/projects
   prefix ➤ /Users/code/go/bin/
   suffix ➤ /Users/code/projects
```

## Installation
1. Clone this repository or download [path-ethic.plugin.zsh](path-ethic.plugin.zsh) to your custom plugins directory.
2. Enable the plugin by adding it to the list of loaded plugins in `~/.zshrc` as follows
```bash 
plugins=(
  git
  path-ethic      # <-- add this line
)
```
3. Add a call to `load_path_ethic` at the end of your `~/.zshrc` (post any `PATH` export!)

```bash
...

export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:/bin/there/done/that

source $HOME/.exports

...

# load path-ethic 
load_path_ethic    # <-- add this line
```
