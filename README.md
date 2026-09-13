# SSH Tools Homebrew Tap

This Homebrew tap provides various SSH-related tools and utilities for macOS.

## Available Formulas

### libsk-libfido2
Library for macOS Yubikey support for SSH with FIDO2 security keys. This enables hardware-based SSH authentication using FIDO2/WebAuthn security keys.

**Installation:**
```bash
brew install michaelroosz/ssh/libsk-libfido2
```

**Post-installation:** Run the following command to complete setup:
```bash
sudo install-libsk-libfido2
```
This installs the library, writes the launch agent and loads it into your GUI
login session.

**Alternative:** Use the automated cask installer (recommended):
```bash
brew install michaelroosz/ssh/libsk-libfido2-install
```

### ssh-tunnel-manager
SSH tunnel management tool implemented with xbar for easy GUI management of SSH tunnels.

**Installation:**
```bash
brew install michaelroosz/ssh/ssh-tunnel-manager
```

**Source:** https://github.com/MichaelRoosz/ssh-tunnel-manager

### sshpass
Non-interactive SSH password authentication tool with a custom fix for the ControlPersist SSH feature.

**Installation:**
```bash
brew install michaelroosz/ssh/sshpass
```

**Source:** https://sourceforge.net/projects/sshpass/

## Available Casks

### libsk-libfido2-install
Automated installer for libsk-libfido2 that handles all configuration automatically.

**Installation:**
```bash
brew install michaelroosz/ssh/libsk-libfido2-install
```

This cask automatically:
- Installs the libsk-libfido2 library
- Configures environment variables
- Sets up launch agents
- Updates shell configuration

Uninstalling the cask reverses all of it:
```bash
brew uninstall --cask michaelroosz/ssh/libsk-libfido2-install
```

Note that `sudo install-libsk-libfido2` (the formula route) writes the same
system files, but `brew uninstall michaelroosz/ssh/libsk-libfido2` only removes
the formula. To clean up afterwards, remove these by hand:
```bash
sudo launchctl bootout "gui/$(id -u)/com.mroosz.ssh_env_vars"
sudo rm /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist
sudo rm /usr/local/lib/libsk-libfido2.dylib
```
and delete the `SSH_SK_PROVIDER` line from your `~/.zshrc`.

## Getting Started

First, add this tap to your Homebrew:
```bash
brew tap michaelroosz/ssh
```

Then install any of the available tools using the installation commands above.
