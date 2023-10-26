cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "9.5p1"
  
  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2.zsh"
  sha256 "be33292d1fe9a9d1c2c000eab900be4962214ba3f59144e5daac29d6ad8a1453"
  
  depends_on arch: [:intel, :arm64]
  depends_on formula: "michaelroosz/ssh/libsk-libfido2"
  depends_on formula: "theseal/ssh-askpass/ssh-askpass"

  postflight do
    system_command "/bin/zsh", args: ["#{staged_path}/install-libsk-libfido2.zsh"], sudo: true
  end

  uninstall_postflight do
    system_command "/bin/zsh", args: ["-c", "rm /usr/local/lib/libsk-libfido2.dylib"], sudo: true
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl unload /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist"], sudo: true
    system_command "/bin/zsh", args: ["-c", "rm /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist"], sudo: true
  end

end
