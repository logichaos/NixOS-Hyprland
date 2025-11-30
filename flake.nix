{
  description = "Logichaos NixOS Setup, based on the one and only JaKooLit!!";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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
          # Host-specific modules will define home-manager.users and users.users
          # based on per-user single-entry files.
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
