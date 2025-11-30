# 💫 https://github.com/JaKooLit 💫 #
# Home Manager configuration for user: default-user (template)

{ config, pkgs, lib, ... }:

{
  # User-specific Home Manager configuration
  # This file can contain user-specific package installations,
  # program configurations, or other HM settings that are unique to this user
  
  # Example: User-specific packages
  home.packages = with pkgs; [
    # Add user-specific packages here
  ];

  # Example: User-specific program configurations
  # programs.git.userName = "JaKooLit";
  # programs.git.userEmail = "ejhay.games@gmail.com";
}
