local script_dir=${0:a:h}

PATH_ETHIC_HOME="$HOME/.path-ethic"
PATH_ETHIC_DEFAULT_PRESET_NAME="default"
PATH_ETHIC_DEFAULT_PRESET_PATH="$PATH_ETHIC_HOME/$PATH_ETHIC_DEFAULT_PRESET_NAME.preset"
PATH_ETHIC_CURRENT_PRESET_NAME="$PATH_ETHIC_DEFAULT_PRESET_NAME"

source "$script_dir/lib.zsh"
source "$script_dir/peth-edit.zsh"
source "$script_dir/peth-presets.zsh"


# Prints help message
function __pe_help() {
    __pe_log "Usage: 
  peth [command] 
  peth command [arguments]


Available Command: 

  show          - shows the effective PATH and your current session settings
  list          - lists all effective PATH elements in the current session
  push <path>   - pushs an element to the begining of the current session PATH
  append <path> - appends an element to the end of the current session PATH
  rm <path>     - finds and removes an element from the session PATH
  flip          - flips the order of your set prefix and suffix in the current 
                  session
  reset         - strips any set prefix and suffix from the current session PATH
  save [name]   - saves the current session settings to disk for later recall
                  If the optional name argument is provided settings are saved 
                  as a preset under that name
  load [name]   - loads previously saved settings into the current session
                  If a name argument is provided attempts to load a saved preset
  rmp [name]    - removes a previously saved preset
  listp         - lists all saved presets
  update        - updates the plugin from github
  help          - displays this help message


 path-ethic on Github: https://github.com/sha1n/path-ethic
  Oh-My-Zsh on Github: https://github.com/ohmyzsh/ohmyzsh
"
}

# Attempts to run self update
function __pe_self_update() {
    if ! __pe_is_directory "$script_dir/.git"; then 
        __pe_log_error "The plugin directory is not a git clone"
        __pe_log_error "Update failed!"
        
        return;
    fi
    
    if read -q "REPLY?Do you want to update 'path-ethic' to the latest version? [Y/n]: "; then
        __pe_log "\nPulling latest changes from remote repository..."

        if git -C "$script_dir" pull origin master; then
            __pe_log "Update successful!"
        else 
            __pe_log_error "Update failed!"
        fi

    else
        __pe_log "\nUpdate cancelled"
    fi    
}

# Main command interpreter and dispatcher function
function peth() {
    if [[ "$#" == "0" ]]; then
        __pe_show
        return
    fi

    while [[ $# -gt 0 ]]; do
        command="$1"

        case $command in
        push)
            __pe_add_path_element "push" "${@:2}"
            return
            ;;
        append)
            __pe_add_path_element "append" "${@:2}"
            return
            ;;
        rm)
            __pe_remove "${@:2}"
            return
            ;;
        reset)
            __pe_reset
            return
            ;;
        save|commit)
            __pe_save "${@:2}"
            return
            ;;
        load|reload)
            __pe_load "${@:2}"
            return
            ;;
        rmp)
            __pe_remove_preset "${@:2}"
            return
            ;;
        listp)
            __pe_list_presets
            return
            ;;
        show)
            __pe_show
            return
            ;;
        list)
            __pe_list
            return
            ;;
        flip)
            __pe_flip
            return
            ;;
        update)
            __pe_self_update
            return
            ;;
        help)
            __pe_help
            return
            ;;
        *) # ignore unknown
            __pe_log_error "unsupported command: '$@'"
            __pe_help
            return
            ;;
        esac
    done
}

# Loads user commited path prefix/suffix and re-exports the shell PATH.
function load_path_ethic() {
    # remove the hook - it is only needed to run once per session
    add-zsh-hook -d precmd load_path_ethic

    # migrate previous version persistent data to latest
    if [[ -f "$HOME/.path-ethic" ]]; then
        local new_path=$(__pe_strip_original_path)
        source "$HOME/.path-ethic"
        export PATH="$(__pe_rebuild_path_with $new_path)"
        
        rm "$HOME/.path-ethic"
        mkdir -p "$PATH_ETHIC_HOME"

        __pe_save      
    fi

    mkdir -p "$PATH_ETHIC_HOME"
    
    if [[ -f "$PATH_ETHIC_DEFAULT_PRESET_PATH" ]]; then
        __pe_load $PATH_ETHIC_DEFAULT_PRESET_NAME
    fi

    # this covers .pethrc in ~
    __pe_load_pethrc
}


function __pe_load_pethrc() {
    local tmp=
    if [[ -f "./.pethrc" ]]; then
        while read line; do
            tmp=$(echo -e "${line}" | tr -d '[:space:]')
            if [[ "$line" != "" ]]; then
                peth load "$line"
            fi
        done <"./.pethrc"
    fi
}
