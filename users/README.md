# Users Directory

This directory contains per-user Home Manager configurations.

## Structure

```
users/
├── common/           # Shared configuration for all users
│   └── default.nix  # Common HM settings
├── <username>/      # Per-user directory
│   ├── default.nix  # User-specific HM configuration
│   ├── variables.nix # User-specific variables (git, browser, etc.)
│   └── dots/        # Optional: User-specific dot-file overrides
```

## Adding a New User

1. Create a directory with the username: `users/<username>/`
2. Create `users/<username>/variables.nix` with user-specific settings:
   ```nix
   {
     gitUsername = "username";
     gitEmail = "user@example.com";
     browser = "firefox";
     terminal = "kitty";
     clock24h = true;
   }
   ```
3. Create `users/<username>/default.nix` for user-specific HM config
4. Add the username to the host's `host-users.nix` file
5. Rebuild the system

## User-Specific Dot-File Overrides

If you want to override specific dot-files from `hm-config/` for a particular user:

1. Create `users/<username>/dots/` directory
2. Mirror the structure from `hm-config/` (e.g., `users/<username>/dots/hypr/`)
3. Add only the files you want to override
4. These will take precedence over the common `hm-config/` files
