class LibskLibfido2 < Formula
    desc "libsk-libfido2 for MacOS Yubikey support for SSH"
    homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
    url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.4p1.tar.gz"
    mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.4p1.tar.gz"
    version "9.4p1"
    sha256 "3608fd9088db2163ceb3e600c85ab79d0de3d221e59192ea1923e23263866a85"
    license "SSH-OpenSSH"
  
    livecheck do
      url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
      regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
    end
    
    depends_on "pkg-config" => :build
    depends_on "ldns"
    depends_on "libfido2"
    depends_on "openssl@3"
  
    uses_from_macos "lsof" => :test
    uses_from_macos "krb5"
    uses_from_macos "libedit"
    uses_from_macos "libxcrypt"
    uses_from_macos "zlib"
  
    on_macos do
      # Both these patches are applied by Apple.
      # https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/sandbox-darwin.c#L66
      patch do
        url "https://raw.githubusercontent.com/Homebrew/patches/1860b0a745f1fe726900974845d1b0dd3c3398d6/openssh/patch-sandbox-darwin.c-apple-sandbox-named-external.diff"
        sha256 "d886b98f99fd27e3157b02b5b57f3fb49f43fd33806195970d4567f12be66e71"
      end
  
      # https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/sshd.c#L532
      patch do
        url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2612fd251ac6de17bf0cc5174c3aab94c/openssh/patch-sshd.c-apple-sandbox-named-external.diff"
        sha256 "3505c58bf1e584c8af92d916fe5f3f1899a6b15cc64a00ddece1dc0874b2f78f"
      end

      # https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/sk-usbhid.c
      patch do
          url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/main/etc/workaround-standalone-libsk.patch"
          sha256 "fc62afdb16636b18bab14e0a8d106c2c9208b225cfa1e3a57ca93301d9d9ff2d"
      end
    end
  
    def install
      if OS.mac?
        ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__"
  
        # Ensure sandbox profile prefix is correct.
        # We introduce this issue with patching, it's not an upstream bug.
        inreplace "sandbox-darwin.c", "@PREFIX@/share/openssh", etc/"ssh"
  
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

      system <<-EOS
        export "$(cat Makefile | grep -m1 'CC=')";
        export "$(cat Makefile | grep -m1 'LDFLAGS=')";
        export "$(cat Makefile | grep -m1 'LIBFIDO2=')";
        echo $LIBFIDO2 | xargs ${CC} -shared openbsd-compat/libopenbsd-compat.a sk-usbhid.o libssh.a -O2 -fPIC -o libsk-libfido2.dylib -Wl,-dead_strip,-exported_symbol,_sk_\*
      EOS

      ENV.deparallelize
      
      lib.install "libsk-libfido2.dylib"
    end
  
    test do
      assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")
  
      port = free_port
      fork { exec sbin/"sshd", "-D", "-p", port.to_s }
      sleep 2
      assert_match "sshd", shell_output("lsof -i :#{port}")
    end
  end
