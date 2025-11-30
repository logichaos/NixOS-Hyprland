# 💫 https://github.com/JaKooLit 💫 #
# Users - Multi-user configuration

{ pkgs, lib, ... }:

let
  # Import the list of users for this host
  hostUsers = import ./host-users.nix;
  
  # Helper function to load per-user single-entry configuration
  mkUserSpec = username:
    let
      defaultPath = ../../users/${username}/default.nix;
      commonDefault = ../../users/common/default.nix;
    in
      if builtins.pathExists defaultPath then
        (import defaultPath { pkgs = pkgs; username = username; })
      else
        (import commonDefault { pkgs = pkgs; username = username; });
  
  # Generate user configurations for all users
  userSpecs = lib.listToAttrs (
    map (username: {
      name = username;
      value = mkUserSpec username;
    }) hostUsers
  );
in
{
  users = { 
    mutableUsers = true;
    users = lib.mapAttrs (_: spec: spec.account) userSpecs;
    defaultUserShell = pkgs.fish;
  }; 

  # Wire Home Manager per-user configs from single-entry files
  home-manager.users = lib.mapAttrs (_: spec: spec.home) userSpecs;
  
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
