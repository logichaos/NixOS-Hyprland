# Migration Guide: Single-User to Multi-User Setup

This guide helps you migrate from the old single-user per host setup to the new multi-user system.

## What Changed?

### Before (Old Structure)
- Username defined in `hosts/<hostname>/variables.nix`
- User-specific settings mixed with host settings
- Single user per host only
- Home Manager configured directly in flake

### After (New Structure)
- Users listed in `hosts/<hostname>/host-users.nix`
- Host and user settings separated
- Multiple users per host supported
- User configs in dedicated `users/<username>/` directories

## Migration Steps

### Step 1: Backup Current Configuration

```bash
cd ~/NixOS-Hyprland
git status  # Make sure you're on the right branch
git add -A
git commit -m "Backup before multi-user migration"
```

### Step 2: Your Configuration is Already Migrated!

The implementation has already migrated the default configurations:

**For `bunny` host**:
- ✅ Created `hosts/bunny/host-users.nix` with `["zephy"]`
- ✅ Created `users/zephy/variables.nix` with your git info, browser, terminal
- ✅ Created `users/zephy/default.nix` for user-specific HM config
- ✅ Updated `hosts/bunny/variables.nix` to only contain host settings
- ✅ Updated `hosts/bunny/users.nix` to read from host-users.nix

**For `default` host** (template):
- ✅ Created `hosts/default/host-users.nix` with `["default-user"]`
- ✅ Created `users/default-user/` configuration
- ✅ Updated host variables and users.nix

### Step 3: Verify the Migration

1. **Check your host's user list**:
   ```bash
   cat hosts/bunny/host-users.nix
   ```
   Should show: `[ "zephy" ]`

2. **Check your user variables**:
   ```bash
   cat users/zephy/variables.nix
   ```
   Should contain your git username, email, browser, terminal, etc.

3. **Check host variables**:
   ```bash
   cat hosts/bunny/variables.nix
   ```
   Should only contain keyboard layout and monitor settings.

### Step 4: Test the Configuration

**Option A: Check flake (no rebuild)**
```bash
nix flake check
```

**Option B: Build without switching**
```bash
sudo nixos-rebuild build --flake .#bunny
```

**Option C: Full rebuild**
```bash
sudo nixos-rebuild switch --flake .#bunny
```

### Step 5: Verify Everything Works

After rebuilding:

1. **Check user account**:
   ```bash
   id zephy
   groups zephy
   ```

2. **Check Home Manager**:
   ```bash
   ls -la ~/.config/hypr
   ls -la ~/.config/waybar
   ```
   These should be symlinks to the repository.

3. **Check Hyprland starts**:
   Log out and back in to test.

## Adding More Users (Post-Migration)

Now that you're on the new system, adding users is easy:

### Example: Add a user named "guest"

1. **Create user directory**:
   ```bash
   mkdir -p users/guest
   ```

2. **Create `users/guest/variables.nix`**:
   ```nix
   {
     gitUsername = "guest";
     gitEmail = "guest@example.com";
     browser = "firefox";
     terminal = "kitty";
     clock24h = true;
   }
   ```

3. **Create `users/guest/default.nix`**:
   ```nix
   { config, pkgs, lib, ... }:
   {
     home.packages = with pkgs; [
       # Guest-specific packages
     ];
   }
   ```

4. **Add to host**:
   Edit `hosts/bunny/host-users.nix`:
   ```nix
   [
     "zephy"
     "guest"
   ]
   ```

5. **Set a password and rebuild**:
   ```bash
   sudo nixos-rebuild switch --flake .#bunny
   sudo passwd guest
   ```

## Customizing Per-User Dot-Files

If different users want different configs:

### Example: Guest wants a simpler Waybar

1. **Create override directory**:
   ```bash
   mkdir -p users/guest/dots/waybar
   ```

2. **Copy and modify**:
   ```bash
   cp hm-config/waybar/config.jsonc users/guest/dots/waybar/
   # Edit users/guest/dots/waybar/config.jsonc with simpler config
   ```

3. **Rebuild**:
   ```bash
   sudo nixos-rebuild switch --flake .#bunny
   ```

Now the guest user will have their custom Waybar config!

## Rollback (If Needed)

If something goes wrong:

1. **Use previous generation**:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

2. **Or boot into previous generation** from GRUB menu

3. **Restore from git** (if you committed backup):
   ```bash
   git log  # Find the backup commit
   git reset --hard <commit-hash>
   ```

## Common Issues

### Issue: "username not found" error

**Cause**: The old flake was passing `username` as a special arg, but the new system doesn't.

**Solution**: Already fixed in the migration. Modules that need username can use:
```nix
{ config, ... }:
let
  username = config.home.username;
in
# ...
```

### Issue: Dot-files not linked

**Cause**: Repository location not detected.

**Solution**: 
1. Ensure repo is at `~/NixOS-Hyprland` or `~/Hyprland-Dots`
2. Check `modules/home/link-dots.nix` - it auto-detects location
3. Rebuild Home Manager configuration

### Issue: User-specific variables not found

**Cause**: User directory missing or incomplete.

**Solution**:
1. Check `users/<username>/variables.nix` exists
2. Verify it has all required fields (gitUsername, gitEmail, browser, terminal, clock24h)
3. Check `hosts/<hostname>/host-users.nix` lists the user

## Verifying the Migration

Run these commands to confirm everything is set up correctly:

```bash
# Check flake structure
nix flake show

# Check host users
cat hosts/bunny/host-users.nix

# Check user config exists
ls -la users/zephy/

# Check host variables are clean
cat hosts/bunny/variables.nix

# Test build
sudo nixos-rebuild build --flake .#bunny

# Check Home Manager links
ls -la ~/.config/ | grep "^l"
```

## Benefits You Now Have

✅ **Multi-user support** - Add unlimited users per host  
✅ **Separated concerns** - Host vs user settings clearly divided  
✅ **Shared configs** - Common dot-files for all users  
✅ **User customization** - Override specific configs per user  
✅ **Easier maintenance** - Cleaner structure, easier to understand  
✅ **Standalone HM** - hm-setup now uses same user configs  

## Need Help?

If you encounter issues:

1. Check the main documentation: `MULTI_USER_SETUP.md`
2. Review user configs in `users/` directory
3. Check host configuration in `hosts/<hostname>/`
4. Review the flake: `flake.nix`
5. Test with a fresh user to isolate issues

## Next Steps

After successful migration:

1. **Commit your changes**:
   ```bash
   git add -A
   git commit -m "Migrated to multi-user setup"
   ```

2. **Consider adding more users** if needed

3. **Customize user-specific configs** as desired

4. **Update documentation** for your specific setup

Happy multi-user NixOS-ing! 🎉
