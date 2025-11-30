{ config, lib, pkgs, ... }:

let
  # Detect repository root (current layout or legacy Hyprland-Dots fallback)
  repoRoot =
    let
      homeDir = config.home.homeDirectory;
      nixosPath = "${homeDir}/NixOS-Hyprland";
      legacyPath = "${homeDir}/Hyprland-Dots";
    in
      if builtins.pathExists nixosPath then nixosPath else legacyPath;

  # Common and user dot paths (new layout)
  commonDotsPath = "${repoRoot}/users/common/dots";
  userDotsPath   = "${repoRoot}/users/${config.home.username}/dots";

  hasCommonDots = builtins.pathExists commonDotsPath;
  hasUserDots   = builtins.pathExists userDotsPath;

  # Helper to create out-of-store symlinks
  mkLink = path: lib.mkIf (path != null && builtins.pathExists path) {
    source = config.lib.file.mkOutOfStoreSymlink path;
  };

  # List top-level directories under a given path
  listTopDirs = path:
    if builtins.pathExists path then
      builtins.filter
        (n: (builtins.readDir path).${n} == "directory")
        (builtins.attrNames (builtins.readDir path))
    else [];

  commonTop = listTopDirs commonDotsPath;
  userTop   = listTopDirs userDotsPath;
  topDirs   = lib.lists.unique (commonTop ++ userTop);

  # Recursively collect relative file paths below a directory
  collectFiles = base: relPrefix:
    let
      full = if relPrefix == "" then base else "${base}/${relPrefix}";
    in
      if !(builtins.pathExists full) then [] else
      let
        entries = builtins.readDir full;
        names = builtins.attrNames entries;
      in lib.concatMap (name:
        let
          t = entries.${name};
          nextRel = if relPrefix == "" then name else "${relPrefix}/${name}";
        in if t == "directory" then collectFiles base nextRel else [ nextRel ]
      ) names;

  # Overlay: per-file precedence of user over common
  buildOverlay = lib.foldl' (acc: top:
    let
      cDir = "${commonDotsPath}/${top}";
      uDir = "${userDotsPath}/${top}";
      files = lib.lists.unique ((collectFiles cDir "") ++ (collectFiles uDir ""));
      fileAttrs = lib.listToAttrs (map (rel:
        let
          uFile = "${uDir}/${rel}";
          cFile = "${cDir}/${rel}";
          chosen = if builtins.pathExists uFile then uFile else cFile;
          target = ".config/${top}/${rel}";
        in { name = target; value = mkLink chosen; }
      ) files);
    in acc // fileAttrs
  ) {} topDirs;

  # Whole-directory fallback (symlink top-level directories)
  buildWholeDirs = lib.listToAttrs (map (top:
    let
      uDir = "${userDotsPath}/${top}";
      cDir = "${commonDotsPath}/${top}";
      chosen = if builtins.pathExists uDir then uDir else cDir;
    in { name = ".config/${top}"; value = mkLink chosen; }
  ) topDirs);

in {
  options.my.dots.overlay.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable per-file overlay of user dotfiles over common dotfiles (users/common/dots).";
  };

  config = lib.mkIf (hasCommonDots || hasUserDots) {
    home.file = if config.my.dots.overlay.enable then buildOverlay else buildWholeDirs;
  };
}
