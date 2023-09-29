cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "9.4p1"
  
  url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2.zsh"
  sha256 "197336326218ff94a31b09a5fd0057f01380b09ef41d1fd2149ef9959e8fe015"
  
  depends_on arch: [:intel, :arm64]
  depends_on formula: "michaelroosz/ssh/libsk-libfido2"

  postflight do
    system_command "/bin/zsh", args: ["#{staged_path}/install-libsk-libfido2.zsh"], sudo: true
  end

  uninstall_postflight do
    lib_path = "/usr/local/lib/libsk-libfido2.dylib"
    if File.exists?(lib_path)
      FileUtils.rm(lib_path)
    end
  end
end
