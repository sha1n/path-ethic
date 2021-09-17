local script_dir=${0:a:h}

PATH_ETHIC_HOME="$HOME/.path-ethic"
PATH_ETHIC_DEFAULT_PRESET_NAME="default"
PATH_ETHIC_DEFAULT_PRESET_PATH="$PATH_ETHIC_HOME/$PATH_ETHIC_DEFAULT_PRESET_NAME.preset"
PATH_ETHIC_CURRENT_PRESET_NAME="$PATH_ETHIC_DEFAULT_PRESET_NAME"

source "$script_dir/peth.zsh"

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
