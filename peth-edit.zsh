source "$PATH_ETHIC_HOME/lib.zsh"

# Removes any set prefix and suffix and re-exports PATH
function __pe_reset() {
    local stripped_path=$(__pe_strip_original_path)
    PATH_ETHIC_HEAD=
    PATH_ETHIC_TAIL=

    __pe_reexport_path "$stripped_path"
}

# Prepends the specified path element re-exports PATH
function __pe_push() {
    PATH_ETHIC_HEAD=$(__pe_normalize_path "$1:$PATH_ETHIC_HEAD")
    __pe_reexport_path
}

# Appends the specified path element re-exports PATH
function __pe_append() {
    PATH_ETHIC_TAIL=$(__pe_normalize_path "$PATH_ETHIC_TAIL:$1")
    __pe_reexport_path
}

function __pe_add_path_element() {
    if [[ "$2" == "" ]]; then
        __pe_log_error "please provide a path to append to PATH"
        __pe_help
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
        __pe_help
        return
    fi

    local find="$1"

    local target_path=$(__pe_strip_original_path)
    target_path=$(__pe_filter "$target_path" "$find")

    PATH_ETHIC_HEAD=$(__pe_filter "$PATH_ETHIC_HEAD" "$find")
    PATH_ETHIC_TAIL=$(__pe_filter "$PATH_ETHIC_TAIL" "$find")

    __pe_reexport_path "$target_path"
}

# Shows the current path elements
function __pe_show() {
    echo "effective ➤ $fg[magenta]$PATH$reset_color
   prefix ➤ $fg[green]$PATH_ETHIC_HEAD$reset_color
   suffix ➤ $fg[blue]$PATH_ETHIC_TAIL$reset_color"
}

# Lists all path elements
function __pe_list() {
    if [[ "$PATH_ETHIC_HEAD" != "" ]]; then
        for e in "${"${(s/:/)PATH_ETHIC_HEAD}"[@]}" 
        do
            echo "$fg[green]$e$reset_color"
        done
    fi
    
    local orig=$(__pe_strip_original_path)
    for e in "${"${(s/:/)orig}"[@]}" 
    do
        echo "$e"
    done

    if [[ "$PATH_ETHIC_TAIL" != "" ]]; then
        for e in "${"${(s/:/)PATH_ETHIC_TAIL}"[@]}" 
        do
            echo "$fg[blue]$e$reset_color"
        done
    fi
}

# Flips the prefix and suffix to change elements priority
function __pe_flip() {
    PATH=$(__pe_strip_original_path)
    
    local tmp=$PATH_ETHIC_HEAD
    PATH_ETHIC_HEAD=$PATH_ETHIC_TAIL
    PATH_ETHIC_TAIL=$tmp

    __pe_reexport_path
}
