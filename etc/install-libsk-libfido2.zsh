#!/bin/zsh

lib_path="/usr/local/lib/libsk-libfido2.dylib"

if [[ "$(uname -m)" == "x86_64" ]]; then
    if [[ -L $lib_path ]]; then
        target=$(realpath $lib_path)
        rm $lib_path
        cp $target $lib_path
    fi
elif [[ "$(uname -m)" == "arm64" ]]; then
    arm_lib_path="/opt/homebrew/lib/libsk-libfido2.dylib"
    if [[ -L $arm_lib_path ]]; then
        target=$(realpath $arm_lib_path)
    fi
    
    mkdir -p /usr/local/lib
    
    if [[ -f $lib_path || -L $lib_path ]]; then
        rm $lib_path
    fi

    cp $target $lib_path
fi
