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
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mroosz.ssh_env_vars</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>/bin/launchctl setenv SSH_ASKPASS ${homebrew_prefix}/bin/ssh-askpass; /bin/launchctl setenv SSH_ASKPASS_REQUIRE force; /bin/launchctl setenv SSH_SK_PROVIDER /usr/local/lib/libsk-libfido2.dylib; /bin/launchctl stop com.openssh.ssh-agent; /bin/launchctl start com.openssh.ssh-agent; /bin/launchctl unsetenv SSH_ASKPASS_REQUIRE</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
