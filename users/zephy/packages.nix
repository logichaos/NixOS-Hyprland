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

  # .NET Development & Azure Tools
  jq                          # Required for NuGet operations in easy-dotnet
  azure-cli                   # Azure command-line interface
  azure-functions-core-tools  # Azure Functions development tools
]
