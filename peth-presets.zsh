source "$PATH_ETHIC_HOME/lib.zsh"

# Loads a saved preset from disk
function __pe_load() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_preset_file_name "$preset_name")
  local preset_path="$PATH_ETHIC_CONFIG/$preset_file_name"

  if [ -f "$preset_path" ]; then
    __pe_reset
    source "$preset_path"

    if [[ "$preset_name" == "$PATH_ETHIC_DEFAULT_PRESET_NAME" ]]; then
      # When loading the default profile, we always load the user rc set PATH
      __pe_reexport_path "$PATH_ETHIC_DEFAULT_PATH"
    else 
      __pe_reexport_path
    fi

    PATH_ETHIC_CURRENT_PRESET_NAME="$preset_name"
  else
    __pe_log_warning "preset file '$preset_path' does not exist"
  fi
}

# Saves or overwrites a preset to disk
function __pe_save() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_preset_file_name "$preset_name")
  local preset_path="$PATH_ETHIC_CONFIG/$preset_file_name"

  echo "PATH_ETHIC_HEAD=$PATH_ETHIC_HEAD" >"$preset_path"
  echo "PATH_ETHIC_TAIL=$PATH_ETHIC_TAIL" >>"$preset_path"
  
  # We only override the actual PATH in non-default presets
  if [[ "$preset_name" != $PATH_ETHIC_DEFAULT_PRESET_NAME ]]; then 
    echo "PATH=$PATH" >>"$preset_path"
  fi

  PATH_ETHIC_CURRENT_PRESET_NAME="$preset_name"
}

# Removes a saved preset from disk
function __pe_remove_preset() {
  if [[ "$1" == "$PATH_ETHIC_CURRENT_PRESET_NAME" ]]; then
    __pe_log_error "can't remove a loaded preset!"
    __pe_log "please use 'peth load [name]' to load another preset first"

    return
  fi

  local preset_file_path=$(__pe_preset_file_path_from "$1")
  if [[ ! -f "$preset_file_path" ]]; then
    __pe_log_warning "preset file '$1' does not exist"
  else
    local confirmed=0
    if [[ -n "$PETH_FORCE" ]]; then
      confirmed=1
    elif read -q "REPLY?Are you sure you want to delete preset '$1'? [Y/n]: "; then
      confirmed=1
    fi

    if [[ $confirmed -eq 1 ]]; then
      rm "$preset_file_path"
      __pe_log "\nPreset '$1' removed."
    fi
  fi
}

# Lists saves presets
function __pe_list_presets() {
  for file in $(find $PATH_ETHIC_CONFIG -type f -iname '*.preset' -maxdepth 1 | awk -F/ '{print $NF}' | sort); do
    local name="${file#"$PATH_ETHIC_CONFIG/"}"
    name="${name%.preset}"
    if [[ "$name" == "$PATH_ETHIC_CURRENT_PRESET_NAME" ]]; then
      echo " $fg[magenta]➤$reset_color $name"
    else
      echo "   $name"
    fi
  done
}

function __pe_preset_name_from() {
  local preset_name="$PATH_ETHIC_DEFAULT_PRESET_NAME"
  if [[ "$1" == "" ]]; then
    preset_name="$PATH_ETHIC_DEFAULT_PRESET_NAME"
  else
    # Remove any characters that are not alphanumeric, underscore, or hyphen
    preset_name="${1//[^a-zA-Z0-9_-]/}"
  fi

  echo "$preset_name"
}

function __pe_preset_file_path_from() {
  local preset_name=$(__pe_preset_name_from "$1")
  local preset_file_name=$(__pe_generate_preset_file_name "$preset_name")

  echo "$PATH_ETHIC_CONFIG/$preset_file_name"
}

function __pe_generate_preset_file_name() {
  echo "$1.preset"
}
