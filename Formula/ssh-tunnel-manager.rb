class SshTunnelManager < Formula
  desc "SSH tunnel management tool impkemented with xbar"
  homepage "https://github.com/MichaelRoosz/ssh-tunnel-manager"
  url "https://github.com/MichaelRoosz/ssh-tunnel-manager/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "16fede91cbbad9c6cafb9acd19901f4370ea14521d8665eb3b76993d89dc59a4"
  version "1.1.0"
  license "GPL-2.0-or-later"

  depends_on "jq"
  depends_on "openssh" => :optional
  depends_on "theseal/ssh-askpass/ssh-askpass"
  
  def install
    bin.install "ssh-tunnel-manager"
  end
end
