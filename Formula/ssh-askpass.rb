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

  bottle do
    root_url "https://ghcr.io/v2/michaelroosz/ssh"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8dc79622d8c2863f59244b1bc8f05eb1f74d43bcfd5d7229753b3577cf548761"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1a1e8052df2c2c4627d0f90f68d3037c3afe2dc434284bc10312cd2285fdc660"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e4a28c005f625296f0548136be8b30ec30772d577f90f51a1dcf2746d72fe131"
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
