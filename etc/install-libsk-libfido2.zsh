#!/bin/zsh

lib_path="/usr/local/lib/libsk-libfido2.dylib"

if [[ "$(uname -m)" == "x86_64" ]]; then
    if [[ -L $lib_path ]]; then
        target=$(readlink $lib_path)
        rm $lib_path
        cp $target $lib_path
    fi
elif [[ "$(uname -m)" == "arm64" ]]; then
    arm_lib_path="/opt/homebrew/lib/libsk-libfido2.dylib"
    if [[ -L $arm_lib_path ]]; then
        target=$(readlink $arm_lib_path)
        rm $arm_lib_path
        cp $target $arm_lib_path
    fi
    cp $arm_lib_path $lib_path
fi
