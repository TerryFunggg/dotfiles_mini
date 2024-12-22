cache_dir=~/.cache
font_dir=~/.local/share/fonts/

if [ ! -d "$cache_dir" ]; then
	mkdir $cache_dir
fi
cd $cache_dir

## Install fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NerdFontsSymbolsOnly.zip
unzip Hack.zip
unzip NerdFontsSymbolsOnly.zip

if [ ! -d "$font_dir" ]; then
	mkdir $font_dir
fi
mv *.ttf $font_dir

fc-cache -fv


