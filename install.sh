#!/usr/bin/env bash
location=$(pwd)
branch=$(git branch)

linking ()
{
	echo "Start to link config files"

	ln -sT $location/bin /home/terryfung/bin
	echo "Installed bin folder"
	ln -s $location/vim/.vimrc /home/terryfung/.vimrc
	echo "Installed tmux config"
	ln -s $location/.gitconfig /home/terryfung/.gitconfig
	echo "Installed git config"

	ln -sT $location/alacritty /home/terryfung/.config/alacritty
	echo "Installed alacritty config"
	ln -sT $location/i3 /home/terryfung/.config/i3
	echo "Installed i3 config"
	ln -sT $location/picom /home/terryfung/.config/picom
	echo "Installed picom config"
	ln -sT $location/ranger /home/terryfung/.config/ranger
	echo "Installed ranger config"
	ln -sT $location/tmux /home/terryfung/.config/tmux
	echo "Installed tmux config"
	ln -sT $location/dunst /home/terryfung/.config/dunst
	echo "Installed dunst config"
	
	ln -s $location/.alias .alias
	echo "source ~/.alias" >> ~/.bashrc
	echo "Imported alias file into bashrc"
	
	ln -sT $location/wallpaper ~/wallpaper
	echo "Installed wallpaper folder"
}

install_font()
{
	echo "Start to install font"

	source $location/font_install.sh
}

distro=''
echo "PWD: $location"
echo "branch: $branch"
read -p "Which distro you are using 1={Ubuntu,Debin} 2={Arch, Manjaro}: " c
case "$c" in
	1 ) echo "Got it! You are using debin or Ubuntu."; distro="sudo apt install";;
	2 ) echo "Okay! I use Arch btw."; distro="sudo pacman -S";;
	* ) echo "Invalid Choice"; exit;;
esac

echo ""
linking

echo ""
echo "Start to install packages(Require root password)..."
source $location/tools_install.sh $distro

echo ""
install_font

echo ""
echo "Finish! Happy Hacking!"

