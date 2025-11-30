#!/usr/bin/env bash
# 💫 https://github.com/JaKooLit 💫 #
# Add User Script - Create a new user configuration

clear

printf "\n%.0s" {1..2}
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘
	Add User Script
\e[0m"
printf "\n%.0s" {1..1}

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

set -e

# Check if we're in the NixOS-Hyprland directory
if [ ! -f "flake.nix" ]; then
    echo "$ERROR This script must be run from the NixOS-Hyprland directory."
    exit 1
fi

# Check if users directory exists
if [ ! -d "users" ]; then
    echo "$ERROR users directory not found."
    exit 1
fi

# Check if default-user template exists
if [ ! -d "users/default-user" ]; then
    echo "$ERROR users/default-user template directory not found."
    exit 1
fi

echo "-----"
printf "\n%.0s" {1..1}

echo "$NOTE This script will create a new user configuration"
echo "$NOTE Default options are in brackets []"
echo "$NOTE Just press enter to select the default"
sleep 1

echo "-----"

# Prompt for username
read -rp "$CAT Enter username for the new user: " userName </dev/tty

# Validate username is not empty
if [ -z "$userName" ]; then
    echo "$ERROR Username cannot be empty."
    exit 1
fi

# Check if user directory already exists
if [ -d "users/$userName" ]; then
    echo "$ERROR User directory 'users/$userName' already exists."
    read -rp "$CAT Do you want to overwrite it? (y/n): " overwrite </dev/tty
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "$NOTE User creation cancelled."
        exit 0
    fi
    echo "$NOTE Removing existing user directory..."
    rm -rf "users/$userName"
fi

echo "-----"

# Prompt for git username
read -rp "$CAT Enter git username: [ $userName ] " gitUsername </dev/tty
if [ -z "$gitUsername" ]; then
    gitUsername="$userName"
fi

# Prompt for git email
read -rp "$CAT Enter git email: [ $userName@example.com ] " gitEmail </dev/tty
if [ -z "$gitEmail" ]; then
    gitEmail="$userName@example.com"
fi

echo "-----"

# Prompt for keyboard layout
read -rp "$CAT Enter keyboard layout: [ us ] " keyboardLayout </dev/tty
if [ -z "$keyboardLayout" ]; then
    keyboardLayout="us"
fi

# Prompt for keyboard variant
read -rp "$CAT Enter keyboard variant (leave empty for default): [ ] " keyboardVariant </dev/tty
if [ -z "$keyboardVariant" ]; then
    keyboardVariant=""
fi

echo "-----"

# Prompt for default shell
echo "$NOTE Available shells: fish (default), zsh, bash"
read -rp "$CAT Enter default shell: [ fish ] " userShell </dev/tty
if [ -z "$userShell" ]; then
    userShell="fish"
fi

# Validate shell choice
if [[ ! "$userShell" =~ ^(fish|zsh|bash)$ ]]; then
    echo "$WARN Invalid shell '$userShell'. Using 'fish' as default."
    userShell="fish"
fi

echo "-----"

# Prompt for description
read -rp "$CAT Enter user description: [ $gitUsername ] " userDescription </dev/tty
if [ -z "$userDescription" ]; then
    userDescription="$gitUsername"
fi

echo "-----"

# Prompt for browser preference
echo "$NOTE Common browsers: firefox (default), vivaldi, google-chrome-stable, brave"
read -rp "$CAT Enter preferred browser: [ firefox ] " userBrowser </dev/tty
if [ -z "$userBrowser" ]; then
    userBrowser="firefox"
fi

# Prompt for terminal preference
echo "$NOTE Common terminals: kitty (default), ghostty, alacritty, wezterm"
read -rp "$CAT Enter preferred terminal: [ kitty ] " userTerminal </dev/tty
if [ -z "$userTerminal" ]; then
    userTerminal="kitty"
fi

echo "-----"

# Create user directory from template
echo "$NOTE Creating user directory for '$userName' from template..."
mkdir -p "users/$userName"
cp -r users/default-user/* "users/$userName/"

# Update variables.nix with user information
echo "$NOTE Configuring user variables..."

sed -i "s/gitUsername = \"[^\"]*\"/gitUsername = \"$gitUsername\"/" "users/$userName/variables.nix"
sed -i "s/gitEmail = \"[^\"]*\"/gitEmail = \"$gitEmail\"/" "users/$userName/variables.nix"
sed -i "s/description = \"[^\"]*\"/description = \"$userDescription\"/" "users/$userName/variables.nix"
sed -i "s/shell = \"[^\"]*\"/shell = \"$userShell\"/" "users/$userName/variables.nix"
sed -i "s/browser = \"[^\"]*\"/browser = \"$userBrowser\"/" "users/$userName/variables.nix"
sed -i "s/terminal = \"[^\"]*\"/terminal = \"$userTerminal\"/" "users/$userName/variables.nix"
sed -i "s/keyboardLayout = \"[^\"]*\"/keyboardLayout = \"$keyboardLayout\"/" "users/$userName/variables.nix"
sed -i "s/keyboardVariant = \"[^\"]*\"/keyboardVariant = \"$keyboardVariant\"/" "users/$userName/variables.nix"

# Copy .zshrc if user selected zsh as default shell
if [ "$userShell" = "zsh" ]; then
    if [ -f "assets/.zshrc" ]; then
        echo "$NOTE Copying default .zshrc for zsh user..."
        mkdir -p "users/$userName/dots"
        cp "assets/.zshrc" "users/$userName/dots/.zshrc"
        echo "$OK Default .zshrc copied to users/$userName/dots/.zshrc"
    else
        echo "$WARN assets/.zshrc not found, skipping..."
    fi
fi

echo "$OK User configuration created successfully!"

echo "-----"
printf "\n%.0s" {1..1}

echo "$NOTE User directory created at: users/$userName"
echo "$NOTE Configuration files:"
echo "  - users/$userName/variables.nix (user settings)"
echo "  - users/$userName/packages.nix (user packages)"
echo "  - users/$userName/default.nix (main user config)"

echo "-----"
printf "\n%.0s" {1..1}

echo "$NOTE To enable this user on a host:"
echo "  1. Edit hosts/<hostname>/host-users.nix"
echo "  2. Add \"$userName\" to the list"
echo "  3. Run: sudo nixos-rebuild switch --flake .#<hostname>"

echo "-----"
printf "\n%.0s" {1..1}

echo "$NOTE After rebuild, set the user password with:"
echo "  sudo passwd $userName"

echo "-----"
printf "\n%.0s" {1..1}

# Ask if user wants to add to current host
read -rp "$CAT Do you want to add this user to a host now? (y/n): " addToHost </dev/tty

if [[ "$addToHost" =~ ^[Yy]$ ]]; then
    # List available hosts
    echo "$NOTE Available hosts:"
    hosts_list=(hosts/*/)
    for i in "${!hosts_list[@]}"; do
        host_name=$(basename "${hosts_list[$i]}")
        echo "  $((i+1)). $host_name"
    done
    
    read -rp "$CAT Enter host name (or number): " hostChoice </dev/tty
    
    # Check if input is a number
    if [[ "$hostChoice" =~ ^[0-9]+$ ]]; then
        # User entered a number
        index=$((hostChoice - 1))
        if [ $index -ge 0 ] && [ $index -lt ${#hosts_list[@]} ]; then
            hostName=$(basename "${hosts_list[$index]}")
        else
            echo "$ERROR Invalid host number."
            exit 1
        fi
    else
        # User entered a name
        hostName="$hostChoice"
    fi
    
    # Check if host exists
    if [ ! -d "hosts/$hostName" ]; then
        echo "$ERROR Host 'hosts/$hostName' not found."
        exit 1
    fi
    
    # Check if host-users.nix exists
    if [ ! -f "hosts/$hostName/host-users.nix" ]; then
        echo "$NOTE host-users.nix not found. Creating it..."
        echo "[ \"$userName\" ]" > "hosts/$hostName/host-users.nix"
        echo "$OK User added to hosts/$hostName/host-users.nix"
    else
        # Check if user already exists in the list
        if grep -q "\"$userName\"" "hosts/$hostName/host-users.nix"; then
            echo "$NOTE User '$userName' already exists in hosts/$hostName/host-users.nix"
        else
            # Add user to the list (before the closing bracket)
            sed -i "s/\]/  \"$userName\"\n]/" "hosts/$hostName/host-users.nix"
            echo "$OK User added to hosts/$hostName/host-users.nix"
        fi
    fi
    
    echo "-----"
    printf "\n%.0s" {1..1}
    
    # Ask if user wants to rebuild now
    read -rp "$CAT Do you want to rebuild the system now? (y/n): " rebuildNow </dev/tty
    
    if [[ "$rebuildNow" =~ ^[Yy]$ ]]; then
        echo "$NOTE Rebuilding NixOS for host '$hostName'..."
        echo "-----"
        
        # Add to git if not already tracked
        git add "users/$userName" "hosts/$hostName/host-users.nix" 2>/dev/null || true
        
        sudo nixos-rebuild switch --flake .#"$hostName"
        
        echo "-----"
        printf "\n%.0s" {1..1}
        echo "$OK System rebuilt successfully!"
        echo "$NOTE Don't forget to set the password for '$userName':"
        echo "  sudo passwd $userName"
    else
        echo "$NOTE Remember to rebuild your system:"
        echo "  sudo nixos-rebuild switch --flake .#$hostName"
    fi
else
    echo "$NOTE User created but not added to any host."
    echo "$NOTE Add manually by editing hosts/<hostname>/host-users.nix"
fi

echo "-----"
printf "\n%.0s" {1..2}

echo "$OK User creation completed!"
