# Packages to install for user: zephy
{ pkgs }:
with pkgs; [
  # shell
  fish
  nix-zsh-completions
  
  # email
  thunderbird

  # scm Jujutsu
  jujutsu
  jjui
  lazyjj
]
