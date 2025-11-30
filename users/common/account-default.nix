# 💫 https://github.com/JaKooLit 💫 #
# Default system account configuration (fallback when user-specific account.nix is missing)

{ pkgs }:
{
  homeMode = "755";
  isNormalUser = true;
  description = "User";
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
    fish
  ];
}
