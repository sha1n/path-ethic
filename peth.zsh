local script_dir=${0:a:h}
source "$script_dir/lib.zsh"

# Loads a saved preset from disk
function __pe_load() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_present_file_name "$preset_name")
  local preset_path="$PATH_ETHIC_HOME/$preset_file_name"

  if [ -f "$preset_path" ]; then
    __pe_reset
    source "$preset_path"
    __pe_reexport_path

    PATH_ETHIC_CURRENT_PRESET_NAME="$preset_name"
  else 
    __pe_log_warning "preset file '$preset_path' does not exist"
  fi
}

# Saves or overwrites a preset to disk
function __pe_save() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_present_file_name "$preset_name")
  local preset_path="$PATH_ETHIC_HOME/$preset_file_name"

  echo "export PATH_ETHIC_HEAD=$PATH_ETHIC_HEAD" > "$preset_path"
  echo "export PATH_ETHIC_TAIL=$PATH_ETHIC_TAIL" >> "$preset_path"

  PATH_ETHIC_CURRENT_PRESET_NAME="$preset_name"
}

# Removes a saved preset from disk
function __pe_remove_preset() {
  if [[ "$1" == "$PATH_ETHIC_CURRENT_PRESET_NAME" ]]; then
      __pe_log_error "can't remove a loaded preset!"
      __pe_log "please use 'path load [name]' to load another preset first"
      
      return;
  fi

  local preset_file_path=$(__pe_present_file_path_from "$1")
  if [[ ! -f "$preset_file_path" ]]; then
    __pe_log_warning "preset file '$1' does not exist"
  else 
    if [[ "$1" == "$PATH_ETHIC_DEFAULT_PRESET_NAME" ]]; then
      if read -q "REPLY?Are you sure you want to delete the default preset? [Y/n]: "; then
        rm "$preset_file_path"
      fi
    else
      rm "$preset_file_path"
    fi
  fi 
}

# Lists saves presets
function __pe_list_presets() {
  for file in $(find $PATH_ETHIC_HOME -type f -mtime -14 -iname '*.preset' -maxdepth 1 | awk -F/ '{print $NF}' | sort); 
  do
    local name="${file#"$PATH_ETHIC_HOME/"}"
    name="${name%.preset}"
    if [[ "$name" == "$PATH_ETHIC_CURRENT_PRESET_NAME" ]]; then
        echo " $fg[magenta]➤$reset_color $name"
    else
        echo "   $name"
    fi
  done
}

# Removes any set prefix and suffix and re-exports PATH
function __pe_reset() {
    local stripped_path=$(__pe_strip_original_path)
    export PATH_ETHIC_HEAD=
    export PATH_ETHIC_TAIL=

    __pe_reexport_path "$stripped_path"
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

    export PATH_ETHIC_HEAD=$(__pe_filter "$PATH_ETHIC_HEAD" "$find")
    export PATH_ETHIC_TAIL=$(__pe_filter "$PATH_ETHIC_TAIL" "$find")

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
    export PATH_ETHIC_HEAD=$PATH_ETHIC_TAIL
    export PATH_ETHIC_TAIL=$tmp

    __pe_reexport_path
}

function __pe_preset_name_from() {
  local preset_name="$PATH_ETHIC_DEFAULT_PRESET_NAME"
  if [[ "$1" == "" ]]; then
    preset_name="$PATH_ETHIC_DEFAULT_PRESET_NAME"
  else 
    preset_name="$1"
  fi

  echo "$preset_name"
}

function __pe_present_file_path_from() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_present_file_name "$preset_name")
  
  echo "$PATH_ETHIC_HOME/$preset_file_name"
}

function __pe_generate_present_file_name() {
    echo "$1.preset"
}
