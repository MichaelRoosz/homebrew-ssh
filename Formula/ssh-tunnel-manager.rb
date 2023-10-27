class SshTunnelManager < Formula
  desc "SSH tunnel management tool impkemented with xbar"
  homepage "https://github.com/MichaelRoosz/ssh-tunnel-manager"
  url "https://github.com/MichaelRoosz/ssh-tunnel-manager/archive/refs/tags/v1.0.10.tar.gz"
  sha256 "e2f0170f396884c7bc6cb73bc1f0778f16d07a5f283b4823e9746b4e97243908"
  license "GPL-2.0-or-later"

  depends_on "jq"
  depends_on "openssh" => :optional
  depends_on "theseal/ssh-askpass/ssh-askpass"
  
  def install
    bin.install "ssh-tunnel-manager"
  end
end
