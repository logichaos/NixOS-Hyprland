{ inputs
 , config
 , lib
 , pkgs
 , ... }:

let
	dotnet9 = pkgs.dotnetCorePackages.sdk_9_0-bin;
	dotnet10 = pkgs.dotnetCorePackages.sdk_10_0-bin;
	dotnet9Wrapper = pkgs.writeShellScriptBin "dotnet-9" ''exec "${dotnet9}/bin/dotnet" "$@"'';
	dotnet10Wrapper = pkgs.writeShellScriptBin "dotnet-10" ''exec "${dotnet10}/bin/dotnet" "$@"'';
in {
	# Provide .NET SDK 9 and 10 in the user profile for developers who need them.
	# Wrap the SDK executables with versioned names to avoid conflicting
	# `/bin/dotnet` entries when both SDKs are present in a buildEnv.
	home.packages = with pkgs; [
		dotnet9Wrapper
		dotnet10Wrapper
	];

}
