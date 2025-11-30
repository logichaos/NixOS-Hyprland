# 💫 https://github.com/JaKooLit 💫 #
# System account configuration for user: zephy

{ pkgs }:
let
  userVars = import ./variables.nix;
in
{
  homeMode = "755";
  isNormalUser = true;
  description = "${userVars.gitUsername}";
  shell = pkgs.fish;
  extraGroups = [
    "networkmanager"
    "wheel"
    "libvirtd"
    "scanner"
    "lp"
    "video"
    "input"
    "audio"
  ];

  packages = with pkgs; [
    nix-zsh-completions
    fish
  ];
}
