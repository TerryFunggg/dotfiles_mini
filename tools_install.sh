#!/usr/bin/env bash
set -e
declare -a tools=(
    "git"
    "wget"
    "tmux"
    "vim"
    "fzf"
    "ranger"
    "i3"
    "picom"
    "dunst"
    "alacritty"
)

$distro ${tools[*]}
