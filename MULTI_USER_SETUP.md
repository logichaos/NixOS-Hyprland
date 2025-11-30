# Multi-User Dot-File Management System

This document describes the streamlined multi-user dot-file management system implemented in this NixOS-Hyprland repository.

## Overview

The repository now supports flexible multi-user configurations with:
- Per-host user lists
- Shared and user-specific dot-file configurations
- Unified structure for both NixOS+HM and standalone HM setups
- Dynamic dot-file linking with user-specific overrides

## Directory Structure

```
NixOS-Hyprland/
├── users/                      # User configurations
│   ├── common/                # Shared across all users
│   │   └── default.nix       # Common HM settings
│   ├── zephy/                # Example user
│   │   ├── default.nix       # User-specific HM config
│   │   ├── variables.nix     # User variables (git, browser, etc.)
│   │   └── dots/             # Optional: User-specific dot-file overrides
│   └── default-user/         # Template user
├── hosts/                     # Host configurations
│   ├── bunny/
│   │   ├── host-users.nix    # List of users on this host
│   │   ├── variables.nix     # Host-specific variables
│   │   ├── config.nix        # System configuration
│   │   ├── users.nix         # User account creation
│   │   └── ...
│   └── default/
├── modules/
│   └── home/
│       ├── link-dots.nix     # Shared dot-file linking module
│       └── default.nix       # Common HM modules
├── hm-config/                 # Common dot-files for all users
│   ├── hypr/
│   ├── waybar/
│   ├── kitty/
│   └── ...
├── hm-setup/                  # Standalone Home Manager setup
│   └── ...
└── flake.nix                  # Main NixOS flake
```

## Key Concepts

### 1. Host-User Mapping

Each host defines its users in `hosts/<hostname>/host-users.nix`:

```nix
# hosts/bunny/host-users.nix
[
  "zephy"
  # Add more users as needed
]
```

### 2. User Configuration

Each user has a directory in `users/<username>/` with:

- **`variables.nix`**: User-specific settings
  ```nix
  {
    gitUsername = "username";
    gitEmail = "user@example.com";
    browser = "firefox";
    terminal = "kitty";
    clock24h = true;
  }
  ```

- **`default.nix`**: User-specific Home Manager configuration
  - User-specific packages
  - Program configurations
  - Any other HM settings unique to this user

- **`dots/` (optional)**: User-specific dot-file overrides
  - Mirrors `hm-config/` structure
  - Only include files you want to override
  - Takes precedence over common configs

### 3. Host Variables

Host-specific settings in `hosts/<hostname>/variables.nix`:

```nix
{
  # Hyprland Settings
  extraMonitorSettings = "";
  
  # Keyboard Layout (host-specific)
  keyboardLayout = "us";
  keyboardVariant = "altgr-intl";
}
```

User-specific variables (git, browser, terminal) are now in `users/<username>/variables.nix`.

### 4. Dot-File Linking

The `modules/home/link-dots.nix` module:
- Auto-detects repository location (`~/NixOS-Hyprland` or `~/Hyprland-Dots`)
- Links `hm-config/` directories to `~/.config/`
- Supports user-specific overrides from `users/<username>/dots/`
- Uses out-of-store symlinks for live editing

**Precedence**: `users/<username>/dots/` > `hm-config/`

### 5. Home Manager Integration

The flake automatically:
1. Reads `host-users.nix` for each host
2. Creates user accounts for all listed users
3. Generates Home Manager configurations for each user
4. Imports:
   - `modules/home/default.nix` - Common programs and dot-file linking
   - `users/common/default.nix` - Shared user settings
   - `users/<username>/default.nix` - User-specific configuration

## Usage

### Adding a New User

1. **Create user directory**:
   ```bash
   mkdir -p users/newuser
   ```

2. **Create `users/newuser/variables.nix`**:
   ```nix
   {
     gitUsername = "newuser";
     gitEmail = "newuser@example.com";
     browser = "firefox";
     terminal = "kitty";
     clock24h = true;
   }
   ```

3. **Create `users/newuser/default.nix`**:
   ```nix
   { config, pkgs, lib, ... }:
   {
     home.packages = with pkgs; [
       # User-specific packages
     ];
   }
   ```

4. **Add to host**:
   Edit `hosts/<hostname>/host-users.nix`:
   ```nix
   [
     "zephy"
     "newuser"  # Add new user
   ]
   ```

5. **Rebuild**:
   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

### Adding User-Specific Dot-File Overrides

If a user needs different configs than the common ones:

1. **Create user dots directory**:
   ```bash
   mkdir -p users/username/dots/hypr
   ```

2. **Add override files**:
   ```bash
   cp hm-config/hypr/hyprland.conf users/username/dots/hypr/
   # Edit the user-specific version
   ```

3. **Rebuild** - the user's config will now use their override

### Using Standalone Home Manager

For systems without NixOS:

```bash
cd hm-setup
home-manager switch --flake .#zephy
```

The standalone setup now uses the same:
- User configurations from `../users/`
- Dot-file linking from `../modules/home/link-dots.nix`
- Common configs from `../hm-config/`

## Migration from Old Structure

### Old Way (Single User per Host)
```nix
# hosts/bunny/variables.nix
{
  username = "zephy";
  gitUsername = "logichaos";
  gitEmail = "...";
  browser = "firefox";
  # ...
}
```

### New Way (Multi-User)

**Host variables** (`hosts/bunny/variables.nix`):
```nix
{
  keyboardLayout = "us";
  keyboardVariant = "altgr-intl";
  extraMonitorSettings = "";
}
```

**Host users** (`hosts/bunny/host-users.nix`):
```nix
[ "zephy" ]
```

**User variables** (`users/zephy/variables.nix`):
```nix
{
  gitUsername = "logichaos";
  gitEmail = "...";
  browser = "firefox";
  terminal = "kitty";
  clock24h = true;
}
```

## Benefits

1. **Multi-User Support**: Multiple users can be configured on a single host
2. **Separation of Concerns**: Host settings vs. user preferences are clearly separated
3. **Shared Modules**: Common dot-files and configurations are shared
4. **User Customization**: Users can override specific configs without duplicating everything
5. **Unified Structure**: Same structure for NixOS+HM and standalone HM
6. **Live Editing**: Out-of-store symlinks allow immediate config changes
7. **Maintainability**: Clear organization makes it easy to add users and manage configs

## Advanced Features

### Per-User Package Lists

In `users/<username>/default.nix`:
```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # User-specific packages
    vscode
    slack
  ];
}
```

### User-Specific Program Configs

```nix
{ pkgs, ... }:
{
  programs.git = {
    userName = "username";
    userEmail = "user@example.com";
    extraConfig = {
      # User-specific git config
    };
  };
}
```

### Conditional User Loading

Hosts automatically load only the users listed in their `host-users.nix`, so you can:
- Have different user sets per host
- Share user configs across multiple hosts
- Easily enable/disable users by editing one file

## Troubleshooting

### Repository Not Found

The `link-dots.nix` module auto-detects:
1. `~/NixOS-Hyprland` (preferred)
2. `~/Hyprland-Dots` (legacy fallback)

If your repo is elsewhere, the symlinks won't work. Clone to one of these locations.

### User-Specific Dots Not Working

1. Check that `users/<username>/dots/` exists
2. Verify the directory structure matches `hm-config/`
3. Ensure files have correct permissions
4. Rebuild Home Manager: `sudo nixos-rebuild switch --flake .#hostname`

### Missing User Variables

If a host lists a user in `host-users.nix` but the user directory doesn't exist:
- Create `users/<username>/` with `default.nix` and `variables.nix`
- Rebuild the system

## Future Enhancements

Possible improvements:
- Per-user theme configurations
- Role-based user templates (developer, designer, etc.)
- Automated user skeleton generation
- User-specific Hyprland workspaces
- Integration with home-manager standalone profiles
