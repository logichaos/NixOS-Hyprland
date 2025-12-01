{ pkgs, username ? "zephy" }:
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
  # System account settings for this user
  account = {
    homeMode = "755";
    isNormalUser = vars.isNormalUser or true;
    description = vars.description or vars.gitUsername;
    shell = shellPkg;
    extraGroups = vars.extraGroups or [
      "networkmanager"
      "wheel"
      "libvirtd"
      "scanner"
      "lp"
      "video"
      "input"
      "audio"
    ];
  };

  # Home Manager configuration for this user
  home = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.11";

    # Include shared HM modules and enable overlay dotfiles
    imports = [
      ../../modules/home/default.nix
    ];

    # Bind git identity from variables (HM 26.05 schema)
    programs.git = {
      enable = true;
      settings.user = {
        name = vars.gitUsername;
        email = vars.gitEmail;
      };
    };
    
    programs.home-manager.enable = true;
    
    # Allow unfree packages (needed for Copilot and other proprietary packages)
    nixpkgs.config.allowUnfree = true;
    
    home.packages = userPackages;
    
    # Keyboard settings for this user (Wayland/Hyprland)
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT = vars.keyboardLayout or "us";
      XKB_DEFAULT_VARIANT = vars.keyboardVariant or "altgr-intl";
    };

  };

  dotsPath = ./dots;
}
