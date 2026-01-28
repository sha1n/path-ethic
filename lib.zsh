

function __pe_strip_original_path() {
    local new_path="$PATH"
    
    if [[ -n "$PATH_ETHIC_HEAD" ]]; then
        local temp="${new_path/$PATH_ETHIC_HEAD:/}"
        if [[ "$temp" == "$new_path" ]]; then
            temp="${new_path/:$PATH_ETHIC_HEAD/}"
        fi
        
        if [[ "$temp" == "$new_path" && "$new_path" == "$PATH_ETHIC_HEAD" ]]; then
            temp=""
        fi
        new_path="$temp"
    fi

    if [[ -n "$PATH_ETHIC_TAIL" ]]; then
        local temp="${new_path/$PATH_ETHIC_TAIL:/}"
        if [[ "$temp" == "$new_path" ]]; then
            temp="${new_path/:$PATH_ETHIC_TAIL/}"
        fi
        
        if [[ "$temp" == "$new_path" && "$new_path" == "$PATH_ETHIC_TAIL" ]]; then
            temp=""
        fi
        new_path="$temp"
    fi

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