#!/bin/bash

if [ "$#" -lt 3 ]; then
  echo 'Usage: gen-module <moduletype> <module-name> <module-category>'
  echo '  moduletype: n (nixos), h (home), or b (both)'
  echo '  module-name: name of the module (e.g., mymodule)'
  echo '  module-category: category of the module (e.g., core, server, desktop, pentesting)'
  exit 1
fi

MODULE_TYPE="$1"
MODULE_NAME="$2"
MODULE_CATEGORY="$3"
DOTS_DIR="$HOME/projects/qnix/qnix-modules"

if [[ ! "$MODULE_TYPE" =~ ^[nhb]$ ]]; then
  echo "Error: moduletype must be 'n' (nixos), 'h' (home), or 'b' (both)"
  exit 1
fi

if [[ ! -d "$DOTS_DIR" ]]; then
  echo "Error: qnix-modules directory not found at $DOTS_DIR"
  exit 1
fi

MODULE_DIR="$DOTS_DIR/modules/$MODULE_CATEGORY/$MODULE_NAME"

if [[ -d "$MODULE_DIR" ]]; then
  echo "Error: Module directory already exists: $MODULE_DIR"
  exit 1
fi

create_nixos_module() {
  local module_file="$MODULE_DIR/nixos/module.nix"
  mkdir -p "$(dirname "$module_file")"
  
  cat > "$module_file" <<EOF
{ lib, config, ... }:

let
  cfg = config.qnix.$MODULE_NAME;
in
{
  config = lib.mkIf cfg.enable {
    # NixOS configuration for $MODULE_NAME
  };
}
EOF
  echo "Created NixOS module: $module_file"
}

create_home_module() {
  local module_file="$MODULE_DIR/home/module.nix"
  mkdir -p "$(dirname "$module_file")"
  
  cat > "$module_file" <<EOF
{ lib, config, ... }:

let
  cfg = config.qnix.$MODULE_NAME;
in
{
  config = lib.mkIf cfg.enable {
    # Home Manager configuration for $MODULE_NAME
  };
}
EOF
  echo "Created Home Manager module: $module_file"
}

create_options() {
  local options_file="$MODULE_DIR/options/options.nix"
  mkdir -p "$(dirname "$options_file")"
  
  cat > "$options_file" <<EOF
{ lib, ... }:

{
  options.qnix.$MODULE_NAME = {
    enable = lib.mkEnableOption "$MODULE_NAME" // {
      default = false;
    };
  };
}
EOF
  echo "Created options: $options_file"
}

# Create module directory structure
mkdir -p "$MODULE_DIR"

# Create options (always needed)
create_options

# Create modules based on type
if [ "$MODULE_TYPE" = "n" ] || [ "$MODULE_TYPE" = "b" ]; then
  create_nixos_module
fi

if [ "$MODULE_TYPE" = "h" ] || [ "$MODULE_TYPE" = "b" ]; then
  create_home_module
fi

echo ""
echo "Module structure created at: $MODULE_DIR"
echo ""

# Run module-update.py to regenerate the index
if [[ -f "$DOTS_DIR/tools/module-update.py" ]]; then
  echo "Regenerating module-index.nix..."
  cd "$DOTS_DIR"
  python3 "$DOTS_DIR/tools/module-update.py" --root "$DOTS_DIR" || {
    echo "Warning: Could not run module-update.py automatically."
    echo "Please run it manually: python3 $DOTS_DIR/tools/module-update.py"
  }
else
  echo "Warning: module-update.py not found. Please regenerate module-index.nix manually."
fi

echo "Done!"

