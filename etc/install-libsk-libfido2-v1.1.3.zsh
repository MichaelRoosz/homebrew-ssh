#!/bin/zsh

dest_lib_path="/usr/local/lib/libsk-libfido2.dylib"

if [[ "$(uname -m)" == "x86_64" ]]; then
  homebrew_prefix=/usr/local
elif [[ "$(uname -m)" == "arm64" ]]; then
  homebrew_prefix=/opt/homebrew
fi

src_lib_path="${homebrew_prefix}/opt/libsk-libfido2/libexec/libsk-libfido2.dylib"
if [[ -L $src_lib_path ]]; then
    src_lib_path=$(realpath $src_lib_path)
fi

mkdir -p /usr/local/lib

if [[ -f $dest_lib_path || -L $dest_lib_path ]]; then
    rm $dest_lib_path
fi

cp $src_lib_path $dest_lib_path

cat <<EOF | tee /Library/LaunchAgents/com.mroosz.ssh_env_vars.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>EnvironmentVariables</key>
        <dict>
                <key>SSH_ASKPASS</key>
                <string>${homebrew_prefix}/bin/ssh-askpass</string>
                <key>SSH_ASKPASS_REQUIRE</key>
                <string>force</string>
                <key>SSH_SK_PROVIDER</key>
                <string>/usr/local/lib/libsk-libfido2.dylib</string>
        </dict>
        <key>Label</key>
        <string>com.mroosz.ssh_env_vars</string>
        <key>ProgramArguments</key>
        <array>
                <string>/usr/bin/ssh-agent</string>
                <string>-l</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>Sockets</key>
        <dict>
                <key>Listeners</key>
                <dict>
                        <key>SecureSocketWithKey</key>
                        <string>SSH_AUTH_SOCK</string>
                        <key>SockFamily</key>
                        <string>Unix</string>
                </dict>
        </dict>
</dict>
</plist>
EOF
