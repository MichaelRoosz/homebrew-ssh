cask "libsk-libfido2-install" do
  version "10.5p1_build2"
  sha256 "f65e110a835c61c6d5d98235dcb440fb1f447945ee341a1faf0b2284c92af5c5"

  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/#{version}/etc/install-libsk-libfido2-v1.1.7.zsh"
  name "libsk-libfido2-install"
  desc "Installer for FIDO2 security key support in SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"

  depends_on arch: [:intel, :arm64]
  depends_on formula: "michaelroosz/ssh/libsk-libfido2"
  depends_on formula: "michaelroosz/ssh/ssh-askpass"

  postflight_steps do
    run "/bin/zsh",
        args: ["{{staged_path}}/install-libsk-libfido2-v1.1.7.zsh", "{{HOMEBREW_PREFIX}}"],
        sudo: true
  end

  uninstall_postflight_steps do
    remove "/usr/local/lib/libsk-libfido2.dylib", sudo: true
    run "/bin/zsh",
        args:         ["-c",
                       "launchctl bootout " \
                       "gui/$(stat -f %u /dev/console)/com.mroosz.ssh_env_vars || true"],
        sudo:         true,
        must_succeed: false
    remove "/Library/LaunchAgents/com.mroosz.ssh_env_vars.plist", sudo: true
    # Drop the two lines the installer added to the console user's ~/.zshrc.
    # This is the only step that edits a file the cask does not own, and it
    # exists because the install side writes those lines -- see the rationale in
    # install-libsk-libfido2-v1.1.7.zsh for why a caveat alone is not enough.
    # Both patterns are fully anchored so nothing else in the file can match,
    # and sed runs as the user to keep the file's ownership intact.
    run "/bin/zsh", sudo: true, must_succeed: false, args: ["-c", <<~'SH']
      user=$(stat -f %Su /dev/console 2>/dev/null) || exit 0
      [ -n "$user" ] || exit 0
      [ "$user" != "root" ] || exit 0
      home=$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null \
        | awk '/^NFSHomeDirectory:/ { print $2 }')
      [ -n "$home" ] || exit 0
      rc="$home/.zshrc"
      [ -f "$rc" ] || exit 0
      sudo -u "$user" /usr/bin/sed -i '' \
        -e '/^# added by install-libsk-libfido2$/d' \
        -e '\|^export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2\.dylib$|d' \
        "$rc"
    SH
  end

  caveats do
    <<~EOS
      The launch agent sets SSH_SK_PROVIDER, SSH_ASKPASS and SSH_ASKPASS_REQUIRE
      for your login session, so terminals opened after logging in inherit them.

      Sessions that do not inherit the launchd environment need the variable
      set explicitly, so the provider path is also added to the console user's
      ~/.zshrc.

      If you use another shell, or another account, add this yourself:
        export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2.dylib
    EOS
  end
end
