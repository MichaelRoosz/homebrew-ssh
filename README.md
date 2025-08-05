# SSH Tools Homebrew Tap

This Homebrew tap provides various SSH-related tools and utilities for macOS.

## Available Formulas

### libsk-libfido2
Library for macOS Yubikey support for SSH with FIDO2 security keys. This enables hardware-based SSH authentication using FIDO2/WebAuthn security keys.

**Installation:**
```bash
brew install michaelroosz/ssh/libsk-libfido2
```

**Post-installation:** Run the following commands to complete setup:
```bash
sudo install-libsk-libfido2
launchctl load /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist
```

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

## Getting Started

First, add this tap to your Homebrew:
```bash
brew tap michaelroosz/ssh
```

Then install any of the available tools using the installation commands above.
