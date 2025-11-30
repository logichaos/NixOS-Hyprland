# 💫 https://github.com/JaKooLit 💫 #
# Users - Multi-user configuration

{ pkgs, lib, ... }:

let
  # Import the list of users for this host
  hostUsers = import ./host-users.nix;
  
  # Helper function to create user configuration
  mkUserConfig = username:
    let
      userVars = import ../../users/${username}/variables.nix;
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

      # define user packages here
      packages = with pkgs; [
        thunderbird
        nix-zsh-completions
        fish
      ];
    };
  
  # Generate user configurations for all users
  userConfigs = lib.listToAttrs (
    map (username: {
      name = username;
      value = mkUserConfig username;
    }) hostUsers
  );
in
{
  users = {
    mutableUsers = true;
    users = userConfigs;
    defaultUserShell = pkgs.fish;
  };

  environment.shells = with pkgs; [ zsh fish ];
  environment.systemPackages = with pkgs; [ lsd fzf git ];
  programs = {
    fish.enable = true;
    zsh = {
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" ];
      };
      # Enable zsh plugins via NixOS module options
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
