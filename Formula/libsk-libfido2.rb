class LibskLibfido2 < Formula
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.4p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.4p1.tar.gz"
  version "10.4p1"
  sha256 "ef6026dd2aea8d56059638d5d3262902c892ceba9f88395835e0d06d3fb63238"
  revision 1
  license "SSH-OpenSSH"
  compatibility_version 1

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  depends_on "pkgconf" => :build
  depends_on "ldns"
  depends_on "libfido2"
  depends_on "openssl@3"
  depends_on "theseal/ssh-askpass/ssh-askpass"

  uses_from_macos "mandoc" => :build
  uses_from_macos "lsof" => :test
  uses_from_macos "krb5"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"

  on_linux do
    depends_on "linux-pam"
    depends_on "zlib-ng-compat"
  end

  resource "install-libsk-libfido2-v1.1.6.zsh" do
    url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.6.zsh"
    sha256 "dc6159e31b70007065ce8abebf33eab6ff9b76a375b7464e8d8f3cd966b04be5"
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    args = %W[
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{formula_opt_prefix("openssl@3")}
      --with-security-key-builtin
    ]

    args << "--with-privsep-path=#{var}/lib/sshd" if OS.linux?

    system "./configure", *args, *std_configure_args

    system "make libssh.a CFLAGS=\"-O2 -fPIC\""
    system "make openbsd-compat/libopenbsd-compat.a CFLAGS=\"-O2 -fPIC\""
    system "make sk-usbhid.o CFLAGS=\"-O2 -DSK_STANDALONE -fPIC\""

    system <<-EOS \
      export "$(cat Makefile | grep -m1 'CC=')" && \
      export "$(cat Makefile | grep -m1 'LDFLAGS=')" && \
      export "$(cat Makefile | grep -m1 'LIBFIDO2=')" && \
      echo $LIBFIDO2 | xargs ${CC} $LDFLAGS -shared openbsd-compat/libopenbsd-compat.a sk-usbhid.o libssh.a -O2 -fPIC -lcrypto -o libsk-libfido2.dylib -Wl,-dead_strip,-exported_symbol,_sk_\*
    EOS

    ENV.deparallelize

    libexec.install "libsk-libfido2.dylib"

    resource("install-libsk-libfido2-v1.1.6.zsh").stage do
      bin.install "install-libsk-libfido2-v1.1.6.zsh" => "install-libsk-libfido2"
    end
  end

  def caveats
    <<~EOF
      !!!

      IMPORTANT: To finish installation run these commands:
        sudo install-libsk-libfido2
        launchctl load /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist

      OR install this homwbrew cask:
        brew install michaelroosz/ssh/libsk-libfido2-install

      !!!
    EOF
  end
end
