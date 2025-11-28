{ inputs
 , config
 , lib
 , pkgs
 , ... }:

let
	dotnet10 = pkgs.dotnetCorePackages.sdk_10_0-bin;
	dotnet10Wrapper = pkgs.writeShellScriptBin "dotnet-10" ''exec "${dotnet10}/bin/dotnet" "$@"'';
in {
	# `/bin/dotnet` entries when both SDKs are present in a buildEnv.
	home.packages = with pkgs; [
		dotnet10Wrapper
        dotnet10
        jetbrains.rider
        podman
        podman-tui
        podman-desktop
        podman-compose
	];

}
