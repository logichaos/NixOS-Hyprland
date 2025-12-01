{ pkgs, ... }:

{
  imports = [
    ./devtools
    ./terminals/tmux.nix
    ./terminals/ghostty.nix
    ./editors/nixvim.nix
    ./editors/vscode.nix
    ./cli/bat.nix
    ./cli/btop.nix
    ./cli/bottom.nix
    ./cli/eza.nix
    ./cli/fzf.nix
    ./cli/git.nix
    ./cli/htop.nix
    ./cli/tealdeer.nix
    ./yazi
  ];

  programs.home-manager.enable = true;
  
  # Add home-manager CLI
  home.packages = with pkgs; [
    home-manager
    kubernetes
  ];
}

