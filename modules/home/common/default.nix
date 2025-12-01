{ inputs
, config
, lib
, pkgs
, ...
}:

{
  home.packages = with pkgs; [
    nfs-utils
  ];

}
