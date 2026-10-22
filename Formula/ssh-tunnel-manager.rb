class SshTunnelManager < Formula
  desc "SSH tunnel management tool implemented with xbar"
  homepage "https://github.com/MichaelRoosz/ssh-tunnel-manager"
  url "https://github.com/MichaelRoosz/ssh-tunnel-manager/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "16fede91cbbad9c6cafb9acd19901f4370ea14521d8665eb3b76993d89dc59a4"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/michaelroosz/ssh"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "82cbda3b0704f8b1872bea7d952f395312fa7d9d1ef3b64d4f49976e257a5fa8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "faede562ef65704e51938232ac6142e979da51484f0e201cfc0c3a5dcc6e8d8c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cb36fa3bd634abbb8af7ee425b44bbde4dc4e1dcac159dcc38ba0abcd0928698"
  end

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
