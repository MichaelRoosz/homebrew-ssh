cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "10.0p2_build1"
  
  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.5.zsh"
  sha256 "cfe0804f1a9baff987c5b3ea5c5a53dd253e485531855e70b92f2e93493eb400"
  
  depends_on arch: [:intel, :arm64]
  depends_on formula: "michaelroosz/ssh/libsk-libfido2"
  depends_on formula: "theseal/ssh-askpass/ssh-askpass"

  postflight do
    system_command "/bin/zsh", args: ["#{staged_path}/install-libsk-libfido2-v1.1.5.zsh"], sudo: true
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl unload /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist &>/dev/null || true"], sudo: false
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl load /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist || true"], sudo: false
    system_command "/bin/zsh", args: ["-c", "echo 'export SSH_SK_PROVIDER=/usr/local/lib/libsk-libfido2.dylib' >> ~/.zshrc || true"], sudo: false
  end

  uninstall_postflight do
    system_command "/bin/zsh", args: ["-c", "rm /usr/local/lib/libsk-libfido2.dylib || true"], sudo: true
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl unload /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist || true"], sudo: false
    system_command "/bin/zsh", args: ["-c", "rm /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist || true"], sudo: true
  end

end
