# 💫 https://github.com/JaKooLit 💫 #
# Common fallback for single-entry user configuration

{ pkgs, username }:
{
  account = {
    homeMode = "755";
    isNormalUser = true;
    description = username;
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
    packages = with pkgs; [ fish ];
  };

  home = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.11";
    imports = [
      ../../modules/home/default.nix
    ];
  };

  dotsPath = null;
}
