class SshAskpass < Formula
  desc "Passphrase dialog for use with OpenSSH in macOS"
  homepage "https://github.com/MichaelRoosz/ssh-askpass/"
  url "https://github.com/MichaelRoosz/ssh-askpass/archive/v1.5.0.tar.gz"
  sha256 "35c27d98aded1261beceba04bb036e17aa33acaf4d04f8027243960fe93c3be7"

  def install
    bin.install name.to_s
    # The label in the plist must be #{plist_name} in order for `brew services` to work
    # See https://github.com/Homebrew/homebrew-services/issues/376
    plist = "#{name}.plist"
    inreplace plist, %r{<string>com.github.theseal.ssh-askpass</string>}, "<string>#{plist_name}</string>"
    inreplace plist, %r{/usr/local/bin}, "#{opt_prefix}/bin"
    prefix.install plist => "#{plist_name}.plist"
  end

  def caveats
    <<~EOF
      NOTE: You will need to run the following to load the SSH_ASKPASS environment variable:
        brew services start #{name}
    EOF
  end

  test do
    system "true"
  end
end
