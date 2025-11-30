# 💫 https://github.com/JaKooLit 💫 #
# Users - Multi-user configuration

{ pkgs, lib, ... }:

let
  # Import the list of users for this host
  hostUsers = import ./host-users.nix;
  
  # Helper function to load per-user account configuration
  mkUserConfig = username:
    let
      accountPath = ../../users/${username}/account.nix;
      defaultAccount = ../../users/common/account-default.nix;
    in
      if builtins.pathExists accountPath then
        (import accountPath { pkgs = pkgs; })
      else
        (import defaultAccount { pkgs = pkgs; });
  
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
