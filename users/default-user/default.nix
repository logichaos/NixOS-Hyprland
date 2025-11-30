# 💫 https://github.com/JaKooLit 💫 #
# Single-entry user configuration for: default-user (template)

{ pkgs, username ? "default-user" }:
let
  vars = import ./variables.nix;
  userPackages = if builtins.pathExists ./packages.nix
    then (import ./packages.nix { pkgs = pkgs; })
    else [];

  shellPkg = if vars.shell or "fish" == "zsh" then pkgs.zsh
             else if vars.shell or "fish" == "bash" then pkgs.bash
             else pkgs.fish;
in
{
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
    packages = userPackages;
  };

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
  };

  dotsPath = ./dots;
}
