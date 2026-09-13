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

### ssh-askpass
Passphrase dialog for OpenSSH, from
[MichaelRoosz/ssh-askpass](https://github.com/MichaelRoosz/ssh-askpass) — a fork
of [theseal/ssh-askpass](https://github.com/theseal/ssh-askpass) (ISC licensed).
It is packaged here so the other formulae in this tap can ship bottles: Homebrew
refuses to bottle a formula whose dependencies are unbottled, and the original
tap publishes none.

**Installation:**
```bash
brew install michaelroosz/ssh/ssh-askpass
```

This formula installs **only the `ssh-askpass` binary**. The original also
shipped a launch agent that ran `launchctl setenv SSH_ASKPASS`, which is exactly
what this tap's own `com.mroosz.ssh_env_vars` agent does — running both would
mean two agents writing the same session variable. As a result
`brew services start ssh-askpass` is **not** supported here; if you relied on it,
keep using `theseal/ssh-askpass` instead.

**Already using `theseal/ssh-askpass`?** The binary is identical (same upstream
tag, same tarball checksum) and the formula name matches, so both share one
Cellar entry: an existing install already satisfies the formulae here and is not
replaced.

Once you are on this version you can drop the original tap, so `brew` no longer
has two formulae with the same name:
```bash
brew untap theseal/ssh-askpass
```
Until you do, plain `brew install ssh-askpass` is ambiguous — use the fully
qualified `michaelroosz/ssh/ssh-askpass`.

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
