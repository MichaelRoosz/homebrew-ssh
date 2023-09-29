cask "libsk-libfido2-install" do
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  version "9.4p1"

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  auto_updates true

  depends_on arch: [:intel, :arm64]
  depends_on formula: "libsk-libfido2"

  lib_path = "/usr/local/lib/libsk-libfido2.dylib"

  preflight do
    if Hardware::CPU.intel?
      if File.symlink?(lib_path)
        target = File.readlink(lib_path)
        FileUtils.rm(lib_path)
        FileUtils.cp(target, lib_path)
      end
    elsif Hardware::CPU.arm?
      arm_lib_path = "/opt/homebrew/lib/libsk-libfido2.dylib"
      if File.symlink?(arm_lib_path)
        target = File.readlink(arm_lib_path)
        FileUtils.rm(arm_lib_path)
        FileUtils.cp(target, arm_lib_path)
      end
      FileUtils.cp(arm_lib_path, lib_path)
    end
  end

  installer manual: "echo 'This cask modifies system files. No additional installation steps required.'"
  
end
