# Ensure add-zsh-hook is loaded
autoload -U add-zsh-hook

local script_dir=${0:a:h}
local env_file_path="$HOME/.path-ethic"
export PATH_ETHIC_TAIL=
export PATH_ETHIC_HEAD=

function __pe_strip_original_path() {
    local new_path=${PATH##"$PATH_ETHIC_HEAD"}
    new_path=${new_path%%"$PATH_ETHIC_TAIL"}

    echo $(__pe_normalize_path $new_path)
}

function __pe_rebuild_path_with() {
    if [[ "$1" == "" ]]; then
        exit 1
    fi

    local new_path="$PATH_ETHIC_HEAD:$1:$PATH_ETHIC_TAIL"

    echo $(__pe_normalize_path $new_path)
}

function __pe_reexport_path() {
    local target_path=
    if [[ "$1" == "" ]]; then
        target_path=$(__pe_strip_original_path)
    else
        target_path="$1"
    fi

    export PATH=$(__pe_rebuild_path_with "$target_path")
}

function __pe_normalize_path() {
    local elements=("${(s/:/)1}")
    local out=

    for e in "${elements[@]}"
    do
        if [[ "$out" == "" ]]; then
            out="$e"
        elif [[ "$e" != "" ]]; then
            out="$out:$e"
        fi
    done
    
    echo $out
}

function __pe_log_error() {
    __pe_log "$fg[red]ERROR:$reset_color $1"
}

function __pe_log_warning() {
    __pe_log "$fg[yellow]WARNING:$reset_color $1"
}

function __pe_log() {
    print "$1" >&2
}

function __pe_is_directory() {
    [ -d "$1" ]
}

# Removes any set prefix and suffix and re-exports PATH
function __pe_reset() {
    local stripped_path=$(__pe_strip_original_path)
    export PATH_ETHIC_HEAD=
    export PATH_ETHIC_TAIL=

    __pe_reexport_path "$stripped_path"

    __pe_show
}

# Prepends the specified path element re-exports PATH
function __pe_push() {
    export PATH_ETHIC_HEAD=$(__pe_normalize_path "$1:$PATH_ETHIC_HEAD")
    __pe_reexport_path
}

# Appends the specified path element re-exports PATH
function __pe_append() {
    export PATH_ETHIC_TAIL=$(__pe_normalize_path "$PATH_ETHIC_TAIL:$1")
    __pe_reexport_path
}

function __pe_add_path_element() {
    if [[ "$2" == "" ]]; then
        __pe_log_error "please provide a path to append to PATH"
        __pe_usage
        return
    fi

    if __pe_is_directory $2 ; then 
        if [[ "$1" == "push" ]]; then
        
            __pe_push "$2"
        
        elif [[ "$1" == "append" ]]; then
        
            __pe_append "$2"
        
        else
            __pe_log_error "unsupported add command '$1'"
        fi

        __pe_show
    
    else
        __pe_log_error "path '$2' doesn't exist"
    fi
}

function __pe_filter() {
    local elements=("${(s/:/)1}")
    local match="$2"
    local out=

    for e in "${elements[@]}"
    do
        if [[ "$e" != "$match" ]]; then
            out="$out:$e"
        fi
    done

    echo $(__pe_normalize_path "$out")
}

# Searches for the specified element in the current PATH and removes it if found
function __pe_remove() {
    if [[ "$1" == "" ]]; then
        __pe_log_error "please provide a path to remove from PATH"
        __pe_usage
        return
    fi

    local find="$1"

    local target_path=$(__pe_strip_original_path)
    target_path=$(__pe_filter "$target_path" "$find")

    export PATH_ETHIC_HEAD=$(__pe_filter "$PATH_ETHIC_HEAD" "$find")
    export PATH_ETHIC_TAIL=$(__pe_filter "$PATH_ETHIC_TAIL" "$find")

    __pe_reexport_path "$target_path"

    __pe_show
}

# Shows the current path elements
function __pe_show() {
    echo "effective ➤ $fg[magenta]$PATH$reset_color
   prefix ➤ $fg[green]$PATH_ETHIC_HEAD$reset_color
   suffix ➤ $fg[blue]$PATH_ETHIC_TAIL$reset_color"
}

function __pe_commit() {
    echo "export PATH_ETHIC_HEAD=\"${PATH_ETHIC_HEAD/$HOME/\$HOME}\"" >$env_file_path
    echo "export PATH_ETHIC_TAIL=\"${PATH_ETHIC_TAIL/$HOME/\$HOME}\"" >>$env_file_path

    __pe_show
}

# Prints usage message
function __pe_usage() {
    __pe_log "
Usage:
  peth [show]
  peth push <path>
  peth append <path>
  peth rm <path>
  peth reset
  peth commit
  peth reload
  peth update
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

# Attempts to run self update
function __pe_reload() {
    local new_path=$(__pe_strip_original_path)

    # Source previously committed environment
    if [[ -f "$env_file_path" ]]; then
        source "$env_file_path"

        export PATH="$(__pe_rebuild_path_with $new_path)"
    fi
}

# Main command interpreter and dispatcher function
function peth() {
    if [[ "$1" == "" ]]; then
        __pe_show
        return
    fi

    while [[ $# -gt 0 ]]; do
        command="$1"

        case $command in
        push)
            __pe_add_path_element "push" "$2"
            return
            ;;
        append)
            __pe_add_path_element "append" "$2"
            return
            ;;
        rm)
            __pe_remove "$2"
            return
            ;;
        commit)
            __pe_commit
            return
            ;;
        reset)
            __pe_reset
            return
            ;;
        reload)
            __pe_reload
            return
            ;;
        show)
            __pe_show
            return
            ;;
        update)
            __pe_self_update
            return
            ;;
        *) # ignore unknown
            __pe_log_error "unsupported command: '$@'"
            __pe_usage
            return
            ;;
        esac
    done
}

# Loads user commited path prefix/suffix and re-exports the shell PATH.
function load_path_ethic() {
    # remove the hook - it is only needed to run once per session
    add-zsh-hook -d precmd load_path_ethic

    __pe_reload
}


# register a pre-command hook to automatically load committed data before the first command is executed.
add-zsh-hook precmd load_path_ethic
