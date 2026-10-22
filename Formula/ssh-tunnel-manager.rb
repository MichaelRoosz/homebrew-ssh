class SshTunnelManager < Formula
  desc "SSH tunnel management tool implemented with xbar"
  homepage "https://github.com/MichaelRoosz/ssh-tunnel-manager"
  url "https://github.com/MichaelRoosz/ssh-tunnel-manager/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "16fede91cbbad9c6cafb9acd19901f4370ea14521d8665eb3b76993d89dc59a4"
  license "MIT"

  depends_on "jq"
  depends_on "michaelroosz/ssh/ssh-askpass"
  depends_on "openssh" => :optional

  def install
    bin.install "ssh-tunnel-manager"
  end

  test do
    ENV["HOME"] = testpath
    (testpath/"ssh-tunnels/empty.json").write "{}"
    output = shell_output("#{bin}/ssh-tunnel-manager")
    assert_match "SSH Tunnels", output
    assert_match "Disconnect All", output
    assert_match "v#{version}", output
  end
end
