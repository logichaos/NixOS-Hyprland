# 💫 https://github.com/JaKooLit 💫 #
# Common Home Manager configuration shared across all users

{ config, pkgs, lib, ... }:

{
  # Common configuration that applies to all users
  # This is imported by every user's HM configuration
  
  # Common packages that all users should have
  home.packages = with pkgs; [
    # Add packages common to all users here
  ];
  
  # Common program configurations
  # These can be overridden in user-specific configs
}
