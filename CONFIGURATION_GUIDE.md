# NixOS Hyprland Configuration Guide

This is a flake-based NixOS configuration with Home Manager integration, designed for easy multi-host and multi-user management.

## 📁 Repository Structure

```
NixOS-Hyprland/
├── flake.nix              # Main flake configuration (auto-discovers hosts)
├── hosts/                 # Per-host configurations
│   ├── bunny/            # Example host
│   │   ├── config.nix    # Main host configuration
│   │   ├── hardware.nix  # Hardware-specific settings
│   │   ├── host-users.nix # List of users for this host
│   │   ├── packages-fonts.nix # Host-specific packages
│   │   └── variables.nix # Host-specific variables
│   └── default/          # Another host example
├── modules/               # Shared system modules
│   ├── packages.nix      # System-wide packages for ALL hosts
│   ├── fonts.nix         # System-wide fonts
│   ├── theme.nix         # System theme configuration
│   └── home/             # Home Manager modules (shared)
│       ├── default.nix   # Main HM imports
│       ├── cli/          # CLI tool configurations
│       ├── editors/      # Editor configurations
│       └── terminals/    # Terminal configurations
└── users/                # Per-user configurations
    ├── zephy/            # Example user
    │   ├── default.nix   # User system + home config
    │   ├── variables.nix # User-specific variables
    │   └── packages.nix  # User-specific packages
    ├── common/           # Fallback/default user config
    └── default-user/     # Template user
```

## 🏠 How to Add a New Host

### Method 1: Using the Installer Script (Recommended)

Run the interactive installer script which automates the entire process:

```bash
./install.sh
```

The installer will:
- ✅ Prompt for a new hostname (or use "default")
- ✅ Create the host directory with template files
- ✅ Detect and configure GPU drivers automatically (NVIDIA, AMD, Intel, or VM)
- ✅ Set up keyboard layout and variant
- ✅ Configure timezone and console keymap
- ✅ Create user directory from `default-user` template
- ✅ Configure git username and email for the user
- ✅ Generate hardware configuration automatically
- ✅ Build and switch to the new configuration
- ✅ Install Hyprland dotfiles and GTK themes

**Note:** The installer creates everything needed for a complete system setup, including user configuration.

### Method 2: Manual Setup

If you prefer manual configuration or are adding a host to an existing system:

1. **Create a new host directory:**
   ```bash
   mkdir -p hosts/myhost
   ```

2. **Copy template files from an existing host:**
   ```bash
   cp hosts/default/* hosts/myhost/
   ```

3. **Edit the host configuration files:**
   - `config.nix` - Main system configuration
   - `hardware.nix` - Hardware settings (run `nixos-generate-config --show-hardware-config > hosts/myhost/hardware.nix`)
   - `host-users.nix` - List users to enable on this host:
     ```nix
     [
       "zephy"
       "anotheruser"
     ]
     ```
   - `packages-fonts.nix` - Host-specific packages and fonts
   - `variables.nix` - Host-specific variables (keyboard layout, timezone, etc.)

4. **The flake automatically discovers your new host** - no need to modify `flake.nix`!

## 🚀 How to Apply a Host Configuration

### Initial Installation
```bash
sudo nixos-rebuild switch --flake ~/NixOS-Hyprland/#myhost
```

### Subsequent Updates
```bash
sudo nixos-rebuild switch --flake .#myhost
```

### Using `nh` (if installed)
```bash
nh os switch
```

### Build and Test (without activating)
```bash
sudo nixos-rebuild build --flake .#myhost
```

## 👤 How to Setup a New User

1. **Create a user directory:**
   ```bash
   mkdir -p users/newuser
   ```

2. **Create `users/newuser/variables.nix`:**
   ```nix
   {
     gitUsername = "Your Name";
     gitEmail = "your.email@example.com";
     
     isNormalUser = true;
     description = "Your Name";
     shell = "fish";  # fish | zsh | bash
     extraGroups = [
       "networkmanager"
       "wheel"
       "video"
       "audio"
     ];
     
     browser = "firefox";
     terminal = "kitty";
     clock24h = true;
   }
   ```

3. **Create `users/newuser/default.nix`:**
   ```nix
   { pkgs, username ? "newuser" }:
   let
     vars = import ./variables.nix;
     userPackages = if builtins.pathExists ./packages.nix
       then (import ./packages.nix { pkgs = pkgs; })
       else [];

     shellPkg = if (vars.shell or "fish") == "zsh" then pkgs.zsh
                else if (vars.shell or "fish") == "bash" then pkgs.bash
                else pkgs.fish;
   in
   {
     # System account settings
     account = {
       homeMode = "755";
       isNormalUser = vars.isNormalUser or true;
       description = vars.description or vars.gitUsername;
       shell = shellPkg;
       extraGroups = vars.extraGroups or [ "wheel" ];
     };

     # Home Manager configuration
     home = {
       home.username = username;
       home.homeDirectory = "/home/${username}";
       home.stateVersion = "25.11";

       imports = [
         ../../modules/home/default.nix
       ];

       programs.git = {
         enable = true;
         settings.user = {
           name = vars.gitUsername;
           email = vars.gitEmail;
         };
       };
       
       home.packages = userPackages;
     };
   }
   ```

4. **Create `users/newuser/packages.nix` (optional):**
   ```nix
   { pkgs }:
   with pkgs; [
     firefox
     thunderbird
     # Add user-specific packages here
   ]
   ```

5. **Add the user to a host:**
   Edit `hosts/myhost/host-users.nix`:
   ```nix
   [
     "zephy"
     "newuser"  # Add this line
   ]
   ```

6. **Set user password after rebuild:**
   ```bash
   sudo passwd newuser
   ```

## 📦 Where to Put Packages

### 1. **All Hosts, System-Wide**
**File:** `modules/packages.nix`

```nix
environment.systemPackages = with pkgs; [
  git
  vim
  firefox
  # Packages available to all users on all hosts
];
```

### 2. **All Users on All Hosts (Home Manager)**
**File:** `modules/home/default.nix`

```nix
home.packages = with pkgs; [
  home-manager
  # Packages in user environment on all hosts
];
```

### 3. **Specific Host Only**
**File:** `hosts/myhost/packages-fonts.nix`

```nix
environment.systemPackages = (with pkgs; [
  steam
  fastfetch
  # Packages only for this host
]);
```

### 4. **Specific User Only**
**File:** `users/username/packages.nix`

```nix
{ pkgs }:
with pkgs; [
  thunderbird
  vscode
  # Packages only for this specific user
]
```

## 🔧 Common Tasks

### Update Flake Inputs
```bash
nix flake update
```

### Update Specific Input
```bash
nix flake lock --update-input nixpkgs
```

### Check Available Hosts
```bash
nix flake show
```

### Garbage Collection
```bash
sudo nix-collect-garbage -d
nix-collect-garbage -d  # User profile cleanup
```

### List Generations
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Rollback to Previous Generation
```bash
sudo nixos-rebuild switch --rollback
```

## 📝 Configuration Priority

From **lowest** to **highest** priority:

1. **System-wide** (`modules/packages.nix`) - Base system packages
2. **Host-specific** (`hosts/myhost/packages-fonts.nix`) - Host overrides
3. **All users** (`modules/home/default.nix`) - Shared user packages
4. **User-specific** (`users/username/packages.nix`) - User overrides

## 🤝 Multi-User Setup

The system automatically:
1. Reads `hosts/myhost/host-users.nix` to get the user list
2. For each user, loads their config from `users/username/default.nix`
3. Falls back to `users/common/default.nix` if user config doesn't exist
4. Creates both system accounts and Home Manager profiles

## 🐛 Troubleshooting

### Home Manager conflicts
If you see backup files with `.hm-bak` extension, Home Manager is preserving existing files. Review and merge or delete them.

### Build fails with "attribute missing"
Ensure your user's `default.nix` returns both `account` and `home` attributes.

### User not found
Check that the username is listed in `hosts/myhost/host-users.nix` and has a corresponding directory in `users/`.

---

**Based on JaKooLit's NixOS-Hyprland configuration**
