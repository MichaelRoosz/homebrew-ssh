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
