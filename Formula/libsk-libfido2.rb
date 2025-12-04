class LibskLibfido2 < Formula
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.2p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.2p1.tar.gz"
  version "10.2p1"
  sha256 "ccc42c0419937959263fa1dbd16dafc18c56b984c03562d2937ce56a60f798b2"
  revision 2
  license "SSH-OpenSSH"

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
  uses_from_macos "zlib"

  on_linux do
    depends_on "linux-pam"
  end

  # Fixes regression with PKCS#11 smart cards. Remove in the next release.
  patch do
    url "https://github.com/openssh/openssh-portable/commit/434ba7684054c0637ce8f2486aaacafe65d9b8aa.patch?full_index=1"
    sha256 "18d311b5819538c235aa48b2e4da9b518e4a82cc4570bff6dae116af28396fb1"
  end

  # Fixes regression with PKCS#11 smart cards. Remove in the next release.
  patch do
    url "https://github.com/openssh/openssh-portable/commit/607f337637f2077b34a9f6f96fc24237255fe175.patch?full_index=1"
    sha256 "b13d736aaabe2e427150ae20afb89008c4eb9e04482ab6725651013362fbc7fe"
  end

  resource "install-libsk-libfido2-v1.1.5.zsh" do
    url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.5.zsh"
    sha256 "cfe0804f1a9baff987c5b3ea5c5a53dd253e485531855e70b92f2e93493eb400"
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    args = %W[
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{Formula["openssl@3"].opt_prefix}
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
      echo $LIBFIDO2 | xargs ${CC} -shared openbsd-compat/libopenbsd-compat.a sk-usbhid.o libssh.a -O2 -fPIC -o libsk-libfido2.dylib -Wl,-dead_strip,-exported_symbol,_sk_\*
    EOS

    ENV.deparallelize

    libexec.install "libsk-libfido2.dylib"

    resource("install-libsk-libfido2-v1.1.5.zsh").stage do
      bin.install "install-libsk-libfido2-v1.1.5.zsh" => "install-libsk-libfido2"
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
