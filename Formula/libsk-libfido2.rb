class LibskLibfido2 < Formula
  desc "Security key provider library for FIDO2 SSH authentication"
  homepage "https://github.com/MichaelRoosz/homebrew-ssh/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz"
  version "10.6p1"
  sha256 "a9dc9565dffe8640f64d863cd29a32bc4a3dbdec0566a7fc44c5d6ee767d5f39"
  license "SSH-OpenSSH"
  revision 1
  compatibility_version 1

  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  depends_on "pkgconf" => :build
  depends_on "ldns"
  depends_on "libfido2"
  depends_on :macos
  depends_on "michaelroosz/ssh/ssh-askpass"
  depends_on "openssl@4"

  uses_from_macos "mandoc" => :build
  uses_from_macos "lsof" => :test
  uses_from_macos "krb5"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"

  resource "install-libsk-libfido2-v1.1.7.zsh" do
    url "https://raw.githubusercontent.com/MichaelRoosz/homebrew-ssh/installer-v1.1.7/etc/install-libsk-libfido2-v1.1.7.zsh"
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
      --with-ssl-dir=#{formula_opt_prefix("openssl@4")}
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

  test do
    (testpath/"test.c").write <<~C
      #include <assert.h>
      #include <dlfcn.h>
      #include <stddef.h>
      #include <stdint.h>

      int main(int argc, char **argv) {
        void *provider = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
        assert(provider != NULL);
        uint32_t (*api_version)(void) = dlsym(provider, "sk_api_version");
        assert(api_version != NULL);
        assert((api_version() & 0xffff0000) == 0x000a0000);
        assert(dlsym(provider, "sk_enroll") != NULL);
        assert(dlsym(provider, "sk_sign") != NULL);
        assert(dlsym(provider, "sk_load_resident_keys") != NULL);
        dlclose(provider);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test"
    system "./test", libexec/"libsk-libfido2.dylib"
  end
end
