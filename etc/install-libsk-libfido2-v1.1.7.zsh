#!/bin/zsh

set -e

dest_lib_path="/usr/local/lib/libsk-libfido2.dylib"
agent_label="com.mroosz.ssh_env_vars"
plist_path="/Library/LaunchAgents/${agent_label}.plist"

homebrew_prefix="$1"

if [[ -z "$homebrew_prefix" ]]; then
  homebrew_prefix="$HOMEBREW_PREFIX"
fi

if [[ -z "$homebrew_prefix" ]] && command -v brew >/dev/null 2>&1; then
  homebrew_prefix="$(brew --prefix)"
fi

# `sudo` may strip the environment and drop `brew` from PATH, so fall back to
# probing the well-known prefixes for an actual Homebrew installation.
if [[ -z "$homebrew_prefix" ]]; then
  for candidate in /opt/homebrew /usr/local; do
    if [[ -x "${candidate}/bin/brew" ]]; then
      homebrew_prefix="$candidate"
      break
    fi
  done
fi

if [[ -z "$homebrew_prefix" ]]; then
  print -u2 "error: could not determine the Homebrew prefix"
  print -u2 "       pass it as the first argument, e.g. sudo $0 \$(brew --prefix)"
  exit 1
fi

# ${...:A} resolves symlinks without depending on realpath(1).
src_lib_path="${homebrew_prefix}/opt/libsk-libfido2/libexec/libsk-libfido2.dylib"
src_lib_path="${src_lib_path:A}"

if [[ ! -f "$src_lib_path" ]]; then
  print -u2 "error: libsk-libfido2.dylib not found at ${src_lib_path}"
  print -u2 "       is michaelroosz/ssh/libsk-libfido2 installed under ${homebrew_prefix}?"
  exit 1
fi

# Only create it when missing: `install -d` chmods the path even when it already
# exists, which would silently reset the mode of a directory Homebrew owns on
# Intel prefixes.
if [[ ! -d /usr/local/lib ]]; then
  install -d -m 755 /usr/local/lib
fi

install -m 755 "$src_lib_path" "$dest_lib_path"

cat <<EOF | tee "$plist_path"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>EnvironmentVariables</key>
	<dict>
		<key>SSH_ASKPASS</key>
		<string>${homebrew_prefix}/bin/ssh-askpass</string>
		<key>SSH_ASKPASS_REQUIRE</key>
		<string>force</string>
		<key>SSH_SK_PROVIDER</key>
		<string>/usr/local/lib/libsk-libfido2.dylib</string>
	</dict>
	<key>Label</key>
	<string>com.mroosz.ssh_env_vars</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>-c</string>
		<string>/bin/launchctl setenv SSH_ASKPASS ${homebrew_prefix}/bin/ssh-askpass; /bin/launchctl setenv SSH_SK_PROVIDER /usr/local/lib/libsk-libfido2.dylib; killall ssh-agent; sock=""; for _ in {1..20}; do sock=\$(/bin/launchctl getenv SSH_AUTH_SOCK); if [ -n "\$sock" ]; then if [ "\$sock" != "\$SSH_AUTH_SOCK_LOCAL" ]; then break; fi; fi; sock=""; sleep 1; done; if [ -n "\$sock" ]; then /bin/ln -sf "\$SSH_AUTH_SOCK_LOCAL" "\$sock"; else /usr/bin/logger -t com.mroosz.ssh_env_vars "SSH_AUTH_SOCK never appeared; agent redirect not installed"; fi; SSH_AUTH_SOCK=\$SSH_AUTH_SOCK_LOCAL /usr/bin/ssh-agent -l</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>Sockets</key>
	<dict>
		<key>Listeners</key>
		<dict>
			<key>SecureSocketWithKey</key>
			<string>SSH_AUTH_SOCK_LOCAL</string>
			<key>SockFamily</key>
			<string>Unix</string>
		</dict>
	</dict>
</dict>
</plist>
EOF

# launchd requires job plists in /Library/LaunchAgents to be root:wheel 0644 and
# skips them otherwise. `tee` derives the mode from the umask on creation and
# keeps the existing mode on reinstall, so set both explicitly.
chown root:wheel "$plist_path"
chmod 644 "$plist_path"

# Load the agent into the console user's GUI domain. This script runs as root,
# so `launchctl bootstrap gui/<uid>` must name that user explicitly -- loading
# it here would otherwise land in root's domain. `bootstrap` is the modern
# replacement for the deprecated `load`; `asuser` is documented as legacy.
console_uid=$(stat -f %u /dev/console 2>/dev/null || true)

if [[ -z "$console_uid" || "$console_uid" == "0" ]]; then
  print -u2 "note: no console user is logged in, so the launch agent was not loaded."
  print -u2 "      once logged in to the desktop, run:"
  print -u2 "        launchctl bootstrap gui/\$(id -u) ${plist_path}"
else
  # bootout first so reinstalling replaces an already-loaded job; both are
  # allowed to fail (bootout when not loaded, bootstrap when already loaded).
  launchctl bootout "gui/${console_uid}/${agent_label}" 2>/dev/null || true
  launchctl bootstrap "gui/${console_uid}" "$plist_path" || true
fi

# Sessions that do not inherit the launchd environment (logging in to this Mac
# over SSH, for example) never see the variables the launch agent sets, so add
# the provider path to the console user's zsh profile as well. Only the static
# provider path is exported: SSH_AUTH_SOCK is per-session, and SSH_ASKPASS
# would be wrong in a session with no GUI to display it.
#
# Writing to a user's shell profile is deliberately NOT what Homebrew itself
# does -- `Utils::Shell.set_variable_in_profile` only ever returns a string for
# the user to run. It is done here because neither of the supported alternatives
# reaches every case:
#
#   * the launchd environment covers GUI apps but not non-GUI sessions;
#   * ssh_config's SecurityKeyProvider/IdentityAgent cover the OpenSSH client
#     but not apps that embed their own SSH stack and only read the environment.
#
# Please do not "correct" this back to a caveats-only approach without a
# replacement that covers both. The uninstall path removes these lines again.
console_user=$(stat -f %Su /dev/console 2>/dev/null || true)

if [[ -n "$console_user" && "$console_user" != "root" ]]; then
  user_home=$(dscl . -read "/Users/${console_user}" NFSHomeDirectory 2>/dev/null \
    | awk '/^NFSHomeDirectory:/ { print $2 }')

  if [[ -n "$user_home" && -d "$user_home" ]]; then
    zshrc="${user_home}/.zshrc"
    sk_export="export SSH_SK_PROVIDER=${dest_lib_path}"

    # Versions before 1.1.7 appended this line on every install, so a long-time
    # user can have many copies. Strip every copy (and our marker) and write
    # exactly one back, which also makes reinstalling idempotent. Both patterns
    # are fully anchored; sed runs as the user to preserve ownership.
    if [[ -f "$zshrc" ]] && grep -qsF -- "$sk_export" "$zshrc"; then
      sudo -u "$console_user" /usr/bin/sed -i '' \
        -e '/^# added by install-libsk-libfido2$/d' \
        -e '\|^export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2\.dylib$|d' \
        "$zshrc"
    fi

    # Written as the user: root must not leave a root-owned file in $HOME.
    sudo -u "$console_user" /usr/bin/tee -a "$zshrc" >/dev/null <<TEE

# added by install-libsk-libfido2
${sk_export}
TEE
    print "SSH_SK_PROVIDER set in ${zshrc}"
  fi
fi
