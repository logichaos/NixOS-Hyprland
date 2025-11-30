{
  # Git Configuration
  gitUsername = "logichaos";
  gitEmail = "logichaoscodes@gmail.com";

  # System account basics
  isNormalUser = true;
  description = "logichaos";
  shell = "fish"; # one of: fish | zsh | bash
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

  # Program Preferences
  browser = "vivaldi"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  
  # Keyboard Settings
  keyboardLayout = "us";
  keyboardVariant = "altgr-intl";
  
  # Waybar Settings
  clock24h = true;
}
