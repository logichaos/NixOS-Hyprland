#!/usr/bin/env bash

# 💫 https://github.com/JaKooLit 💫 #
# NixOS Host Installation Script

clear

printf "\n%.0s" {1..2}
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ 2025
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ 
	    NixOS Host Installation Script
\e[0m"
printf "\n%.0s" {1..1}

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

set -e

# Common installer functions
if [ -f "scripts/lib/install-common.sh" ]; then
    # shellcheck source=/dev/null
    . "scripts/lib/install-common.sh"
fi

# Verify this is NixOS
if [ -n "$(grep -i nixos </etc/os-release)" ]; then
    echo "$OK Verified this is NixOS."
    echo "-----"
else
    echo "$ERROR This is not NixOS or the distribution information is not available."
    exit 1
fi

# Check if we're in the correct directory
if [ ! -f "flake.nix" ]; then
    echo "$ERROR flake.nix not found. Please run this script from the NixOS-Hyprland directory."
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTS_DIR="$SCRIPT_DIR/hosts"

# Get list of available hosts (excluding 'default')
echo "$INFO Scanning for available hosts..."
AVAILABLE_HOSTS=()
for host_dir in "$HOSTS_DIR"/*; do
    if [ -d "$host_dir" ]; then
        hostname=$(basename "$host_dir")
        if [ "$hostname" != "default" ]; then
            AVAILABLE_HOSTS+=("$hostname")
        fi
    fi
done

if [ ${#AVAILABLE_HOSTS[@]} -eq 0 ]; then
    echo "$ERROR No hosts found (excluding 'default')."
    echo "$NOTE Please create a host directory first using add-host.sh"
    exit 1
fi

# Display available hosts
echo ""
echo "$CAT Available hosts for installation:"
echo "-----"
for i in "${!AVAILABLE_HOSTS[@]}"; do
    echo "$GREEN$((i+1)).$RESET ${AVAILABLE_HOSTS[$i]}"
done
echo "-----"

# Ask user to select a host
echo ""
read -p "$(echo -e ${YELLOW}Enter the number of the host you want to install:${RESET} )" selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#AVAILABLE_HOSTS[@]} ]; then
    echo "$ERROR Invalid selection. Please run the script again."
    exit 1
fi

# Get selected hostname
SELECTED_HOST="${AVAILABLE_HOSTS[$((selection-1))]}"
HOST_DIR="$HOSTS_DIR/$SELECTED_HOST"

echo ""
echo "$INFO Selected host: $GREEN$SELECTED_HOST$RESET"
echo "-----"

# Confirm before proceeding
echo ""
read -p "$(echo -e ${YELLOW}This will generate hardware configuration for ${GREEN}$SELECTED_HOST${YELLOW}. Continue? (y/n):${RESET} )" confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "$NOTE Installation cancelled."
    exit 0
fi

# Generate hardware configuration
echo ""
echo "$CAT Generating hardware configuration..."
if sudo nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware.nix"; then
    echo "$OK Hardware configuration saved to $HOST_DIR/hardware.nix"
else
    echo "$ERROR Failed to generate hardware configuration."
    exit 1
fi

echo "-----"

# Confirm before applying configuration
echo ""
read -p "$(echo -e ${YELLOW}Apply NixOS configuration for ${GREEN}$SELECTED_HOST${YELLOW} now? (y/n):${RESET} )" apply_confirm

if [[ ! "$apply_confirm" =~ ^[Yy]$ ]]; then
    echo "$NOTE Configuration generated but not applied."
    echo "$INFO To apply later, run: sudo nixos-rebuild switch --flake ~/NixOS-Hyprland/#$SELECTED_HOST"
    exit 0
fi

# Apply the configuration
echo ""
echo "$CAT Applying NixOS configuration for $SELECTED_HOST..."
echo "$NOTE This may take a while..."
echo "-----"

if sudo nixos-rebuild switch --flake ~/NixOS-Hyprland/#"$SELECTED_HOST"; then
    echo ""
    echo "-----"
    echo "$OK NixOS configuration for $GREEN$SELECTED_HOST$RESET applied successfully!"
    echo "$NOTE You may need to reboot for all changes to take effect."
    echo "-----"
else
    echo ""
    echo "-----"
    echo "$ERROR Failed to apply NixOS configuration."
    echo "$NOTE Please check the error messages above for details."
    exit 1
fi

echo ""
read -p "$(echo -e ${YELLOW}Would you like to reboot now? (y/n):${RESET} )" reboot_confirm

if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
    echo "$INFO Rebooting system..."
    sudo reboot
else
    echo "$NOTE Please reboot your system when ready to complete the installation."
fi
