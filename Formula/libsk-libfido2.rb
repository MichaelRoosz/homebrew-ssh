class LibskLibfido2 < Formula
  desc "libsk-libfido2 for MacOS Yubikey support for SSH"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p2.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p2.tar.gz"
  version "10.0p2"
  sha256 "021a2e709a0edf4250b1256bd5a9e500411a90dddabea830ed59cef90eb9d85c"
  revision 1
  license "SSH-OpenSSH"

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end
  
  depends_on "pkg-config" => :build
  depends_on "ldns"
  depends_on "libfido2"
  depends_on "openssl@3"
  depends_on "theseal/ssh-askpass/ssh-askpass"

  uses_from_macos "lsof" => :test
  uses_from_macos "krb5"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  resource "install-libsk-libfido2-v1.1.5.zsh" do
    url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/install-libsk-libfido2-v1.1.5.zsh"
    sha256 "cfe0804f1a9baff987c5b3ea5c5a53dd253e485531855e70b92f2e93493eb400"
  end

  def install
    if OS.mac?
      ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__"

      # FIXME: `ssh-keygen` errors out when this is built with optimisation.
      # Reported upstream at https://bugzilla.mindrot.org/show_bug.cgi?id=3584
      # Also can segfault at runtime: https://github.com/Homebrew/homebrew-core/issues/135200
      if Hardware::CPU.intel? && DevelopmentTools.clang_build_version == 1403
        inreplace "configure", "-fzero-call-used-regs=all", "-fzero-call-used-regs=used"
      end
    end

    args = *std_configure_args + %W[
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{Formula["openssl@3"].opt_prefix}
      --with-security-key-builtin
    ]

    args << "--with-privsep-path=#{var}/lib/sshd" if OS.linux?

    system "./configure", *args

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
