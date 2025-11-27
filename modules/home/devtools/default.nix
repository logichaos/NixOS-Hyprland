{ inputs
 , config
 , lib
 , pkgs
 , ... }:

{
	# Provide .NET SDK 9 and 10 in the user profile for developers who need them.
	# These package names follow the pattern used elsewhere in this repo (hosts/*).
	home.packages = with pkgs; [
		dotnetCorePackages.sdk_9_0-bin
		dotnetCorePackages.sdk_10_0-bin
	];

}
