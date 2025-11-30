{
  description = "KooL's NixOS-Hyprland";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    #hyprland.url = "github:hyprwm/Hyprland"; # hyprland development
    #distro-grub-themes.url = "github:AdisonCavani/distro-grub-themes";

    ags = {
      type = "github";
      owner = "aylur";
      repo = "ags";
      ref = "v1";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ self
    , nixpkgs
    , ags
    , ...
    }:
    let
      system = "x86_64-linux";

      # Helper function to create a NixOS configuration for a host
      mkHost = host:
        let
          # Import the list of users for this host
          hostUsers = import ./hosts/${host}/host-users.nix;
          
          # Helper to create HM config for a single user
          mkUserHMConfig = username: {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            home.stateVersion = "25.11";

            # Import common HM modules, user-specific config, and common user config
            imports = [
              ./modules/home/default.nix      # Common programs (git, nvim, etc.) and dot-file linking
              ./users/common/default.nix      # Shared across all users
              ./users/${username}/default.nix # User-specific HM configuration
            ];
          };
          
          # Generate home-manager.users attrset for all users on this host
          hmUsers = nixpkgs.lib.listToAttrs (
            map (username: {
              name = username;
              value = mkUserHMConfig username;
            }) hostUsers
          );
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit host;
          };
          modules = [
            ./hosts/${host}/config.nix
            # inputs.distro-grub-themes.nixosModules.${system}.default
            ./modules/overlays.nix # nixpkgs overlays (CMake policy fixes)
            ./modules/quickshell.nix # quickshell module
            ./modules/packages.nix # Software packages
            # Allow broken packages (temporary fix for broken CUDA in nixos-unstable)
            { nixpkgs.config.allowBroken = true; }
            ./modules/fonts.nix # Fonts packages
            ./modules/portals.nix # portal
            ./modules/theme.nix # Set dark theme
            ./modules/ly.nix # ly greater with matrix animation
            inputs.catppuccin.nixosModules.catppuccin
            # Integrate Home Manager as a NixOS module
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";

              # Ensure HM modules can access flake inputs
              home-manager.extraSpecialArgs = { inherit inputs system host; };

              # Configure Home Manager for all users on this host
              home-manager.users = hmUsers;
            }
          ];
        };

      # Auto-discover all hosts from the hosts/ directory
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs
          (name: type: type == "directory")
          (builtins.readDir ./hosts)
      );

    in
    {
      # Generate nixosConfigurations for each discovered host
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames mkHost;
    };
}
