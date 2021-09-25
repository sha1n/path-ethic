PATH_ETHIC_HOME="${${(%):-%x}:a:h}"

source "$PATH_ETHIC_HOME/peth.zsh"

################################################################################

# Ensure add-zsh-hook is loaded
autoload -U add-zsh-hook

# register completion functions for 'path-ethic'
fpath=(${0:a:h}/completion $fpath)

# register a change dir hook to automatically load optional .pethrc
add-zsh-hook chpwd __pe_load_pethrc

# register a pre-command hook to automatically load committed data before the
# first command is executed.
add-zsh-hook precmd load_path_ethic
