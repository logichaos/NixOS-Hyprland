{ inputs
 , config
 , lib
 , pkgs
 , ...
}:

{
	programs.vscode = {
		enable = true;
		package = pkgs.vscode;
	};

	# Useful helper packages for development tooling (available in the user profile)
	home.packages = with pkgs; [
		nodejs
		yarn
		ripgrep
		fd
		bat
	];
}
