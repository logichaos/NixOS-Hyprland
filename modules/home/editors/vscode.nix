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

		settings = {
			"editor.formatOnSave" = true;
			"files.trimTrailingWhitespace" = true;
			"telemetry.enableTelemetry" = false;
			"telemetry.enableCrashReporter" = false;
		};
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
