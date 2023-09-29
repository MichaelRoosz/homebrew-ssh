cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "9.4p1"
  
  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2.zsh"
  sha256 "0502670378365109175e09c645a6b7acdb743f9f9669c53335411a88c6efc84c"
  
  depends_on arch: [:intel, :arm64]
  depends_on formula: "libsk-libfido2"

  postflight do
    system_command "/bin/zsh", args: ["#{staged_path}/install-libsk-libfido2.zsh"], sudo: true
  end
end
