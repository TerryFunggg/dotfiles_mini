#!/usr/bin/env bash
set -e
declare -a tools=(
    "git"
    "unzip"
    "wget"
    "tmux"
    "vim"
    "fzf"
    "ranger"
    "i3"
    "picom"
    "dunst"
    "w3m"
    "feh"
    "dmenu"
    "mutt"
    "neomutt"
    #"alacritty"
)

$distro ${tools[*]}
