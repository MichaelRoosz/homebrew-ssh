cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "9.5p1_build3"
  
  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.2.zsh"
  sha256 "4cfb4931444a06484b67567e8c3d363c53b7647d728327bfbcdd30d23a64eac9"
  
  depends_on arch: [:intel, :arm64]
  depends_on formula: "michaelroosz/ssh/libsk-libfido2"
  depends_on formula: "theseal/ssh-askpass/ssh-askpass"

  postflight do
    system_command "/bin/zsh", args: ["#{staged_path}/install-libsk-libfido2-v1.1.2.zsh"], sudo: true
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl load /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist"], sudo: false
  end

  uninstall_postflight do
    system_command "/bin/zsh", args: ["-c", "rm /usr/local/lib/libsk-libfido2.dylib"], sudo: true
    system_command "/bin/zsh", args: ["-c", "/bin/launchctl unload /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist"], sudo: false
    system_command "/bin/zsh", args: ["-c", "rm /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist"], sudo: true
  end

end
