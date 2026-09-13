class LibskLibfido2 < Formula
  desc "Security key provider library for FIDO2 SSH authentication"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.5p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.5p1.tar.gz"
  version "10.5p1"
  sha256 "d44d28a839ea9daf969cc69150fde59910b2b39361dad81a3bd6cbd19218db11"
  license "SSH-OpenSSH"
  revision 2
  compatibility_version 1

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  depends_on "pkgconf" => :build
  depends_on "ldns"
  depends_on "libfido2"
  # The build emits a Mach-O .dylib and the installer script uses launchctl,
  # dscl and /Library/LaunchAgents, so this is macOS-only.
  depends_on :macos
  depends_on "openssl@3"
  depends_on "theseal/ssh-askpass/ssh-askpass"

  uses_from_macos "mandoc" => :build
  uses_from_macos "lsof" => :test
  uses_from_macos "krb5"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"

  resource "install-libsk-libfido2-v1.1.7.zsh" do
    url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.7.zsh"
    sha256 "f65e110a835c61c6d5d98235dcb440fb1f447945ee341a1faf0b2284c92af5c5"
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

    system <<-EOS
      export "$(cat Makefile | grep -m1 'CC=')" && \
      export "$(cat Makefile | grep -m1 'LDFLAGS=')" && \
      export "$(cat Makefile | grep -m1 'LIBFIDO2=')" && \
      echo $LIBFIDO2 | xargs ${CC} $LDFLAGS -shared openbsd-compat/libopenbsd-compat.a sk-usbhid.o libssh.a -O2 -fPIC -lcrypto -o libsk-libfido2.dylib -Wl,-dead_strip,-exported_symbol,_sk_*
    EOS

    ENV.deparallelize

    libexec.install "libsk-libfido2.dylib"

    resource("install-libsk-libfido2-v1.1.7.zsh").stage do
      bin.install "install-libsk-libfido2-v1.1.7.zsh" => "install-libsk-libfido2"
    end
  end

  def caveats
    <<~EOF
      !!!

      IMPORTANT: To finish installation run this command:
        sudo install-libsk-libfido2

      It installs the library, writes the launch agent and loads it into your
      GUI login session.

      OR install this homebrew cask:
        brew install michaelroosz/ssh/libsk-libfido2-install

      !!!
    EOF
  end
end
