class SshAskpass < Formula
  desc "Passphrase dialog for use with OpenSSH"
  homepage "https://github.com/MichaelRoosz/ssh-askpass"
  url "https://github.com/MichaelRoosz/ssh-askpass/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "7497125e452e1cfe671ac05dbb4640f5d82ba6961950c0e519a00afdd8be0880"
  license "ISC"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Fork of theseal/ssh-askpass. Packaged here so the other formulae in this tap
  # can ship bottles: Homebrew refuses to bottle a formula whose dependencies
  # are unbottled, and the original tap publishes none.
  #
  # Only the binary is installed. The upstream formula also shipped a launch
  # agent that ran `launchctl setenv SSH_ASKPASS`, which is exactly what this
  # tap's own com.mroosz.ssh_env_vars agent does, so keeping both would mean two
  # agents writing the same session variable.
  #
  # The formula name matches the original, so this shares the `ssh-askpass` rack
  # (Formula#rack is HOMEBREW_CELLAR/name, with no tap component) and an
  # existing install from that tap already satisfies this formula's dependents.

  depends_on :macos

  def install
    bin.install "ssh-askpass"
  end

  test do
    assert_path_exists bin/"ssh-askpass"
  end
end
