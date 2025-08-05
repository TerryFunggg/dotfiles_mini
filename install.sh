#!/usr/bin/env bash
set -e
set -u
LOG_FILE="/tmp/ty-dotfiles.log"
# clean previous log content
: > "$LOG_FILE"

location=$(pwd)
branch=$(git branch)
user=$USER
xprofile="$HOME/.xprofile"
# folder for font download
font_cache_dir=~/.cache/ty-dotfile-fonts
# font installed location
font_dist_dir=~/.local/share/fonts/

declare -a tools=(
    "make" "gcc" "git" "unzip" "wget" "tmux" "vim"
    "fzf" "ranger" "i3" "picom" "dunst" "w3m" "feh"
    "dmenu" "pulsemixer" "xfce4" "xfce4-screenshooter"
    "alacritty" "htop"
)

log() {
  echo -e "$1"
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"  
}


install_config_files() {
    echo ""
    echo -e "\n$(cat <<'EOF'
 _     _       _    _
| |   (_)_ __ | | _(_)_ __   __ _
| |   | | '_ \| |/ / | '_ \ / _` |
| |___| | | | |   <| | | | | (_| |
|_____|_|_| |_|_|\_\_|_| |_|\__, |
                            |___/
EOF
    )\n"

    log "🔗 Linking config files..."

    # Ensure ~/.config exists
    mkdir -p "$HOME/.config"

    backup_and_link() {
        local src="$1"
        local dest="$2"
        local type="${3:-file}"

        if [ -e "$dest" ] || [ -L "$dest" ]; then
            mv "$dest" "${dest}.bak"
            log "🗂️ Backed up: $dest → ${dest}.bak"
        fi
        ln -sfT "$src" "$dest"
        log "🔗 Linked: $dest"
    }

    backup_and_link "$location/bin" "$HOME/bin"

    backup_and_link "$location/vim/.vimrc" "$HOME/.vimrc"
    backup_and_link "$location/.gitconfig" "$HOME/.gitconfig"
    backup_and_link "$location/.alias" "$HOME/.alias"

    # ~/.config/*
    for config in alacritty i3 picom ranger tmux dunst; do
        backup_and_link "$location/$config" "$HOME/.config/$config"
    done

    # Wallpaper folder
    backup_and_link "$location/wallpaper" "$HOME/wallpaper"
}

install_font()
{
    echo ""
    echo -e "\n$(cat <<'EOF'
 _____           _
|  ___|__  _ __ | |_
| |_ / _ \| '_ \| __|
|  _| (_) | | | | |_
|_|  \___/|_| |_|\__|

EOF
    )\n"
    log "🔤 Starting font installation..."
    mkdir -p $font_cache_dir
    mkdir -p $font_dist_dir
    
    local previous=$(pwd)
    cd "$font_cache_dir" || { log "❌ Failed into font cache directory"; return 1; }

    # Font URLs
    fonts=(
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip"
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NerdFontsSymbolsOnly.zip"
        "https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u%2F1.062R-i%2F1.026R-vf/TTF-source-code-pro-2.042R-u_1.062R-i.zip"
    )

    for url in "${fonts[@]}"; do
        file=$(basename "$url")
        log "⬇️ Downloading $file..."
        wget -q --show-progress "$url"

        log "📂 Unzipping $file..."
        unzip -o "$file"
    done
    
    mv *.ttf $font_dist_dir
    mv ./TTF/*.ttf $font_dist_dir
    
    fc-cache -f >/dev/null 2>>"$LOG_FILE"

    cd $previous
}

install_tools() {
    set +e
    local os="$1"
    echo ""
    echo -e "\n$(cat <<'EOF'
 _____           _
|_   _|__   ___ | |___
  | |/ _ \ / _ \| / __|
  | | (_) | (_) | \__ \
  |_|\___/ \___/|_|___/

EOF
    )\n"
    log "📦 Installing essential tools..."
    log "${tools[*]}"
    
    # install basic tools required
    for tool in "${tools[@]}"; do
        log "🔧 Installing: $tool"
        if [ "$os" -eq 1 ]; then
            sudo apt install -y $tool >/dev/null 2>>"$LOG_FILE"
        elif [ "$os" -eq 2]; then
            sudo pacman -S --noconfirm $tool >/dev/null 2>>"$LOG_FILE"
        fi

        if [ $? -eq 0 ]; then
            log "✅ $tool installed successfully."
        else
            log "⚠️ Failed to install $tool. You may need to check your package manager or sources."
            log "Stop the installing, please check the issue fisrt"
            exit 1
        fi
    done

    set -e
}

install_mise() {
    echo ""

    install_language_from_mise() {
        # Ensure mise is available in current shell
        export PATH="$HOME/.local/bin:$PATH"
        eval "$(mise activate bash)"

        echo ""
        log "🐍 Installing Python via Mise..."
        mise use -g python@latest
        log "✅ Python installed and set as global default via Mise."

        echo ""
        log "🟢 Installing Node.js (latest LTS) via Mise..."
        mise use -g node@lts
        log "✅ Node.js LTS installed and set as global default."
    }

    # Check if mise is already installed
    if command -v mise &>/dev/null; then
        log "✅ Mise is already installed."
        install_language_from_mise
        return 0
    fi

    log "📦 Installing Mise (runtime version manager)..."

    # Run the official install script
    curl https://mise.run | bash

    # Add mise to shell profile
    if [ -n "$ZSH_VERSION" ]; then
        echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
    fi
    if [ -n "$BASH_VERSION" ]; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    fi

    log "✅ Mise installed successfully."
    install_language_from_mise

}

install_wal() {
    echo ""
    # Check if wal is already installed
    if command -v wal &>/dev/null; then
        log "✅ pywal is already installed."
        return 0
    fi

    log "🎨 Installing pywal (wal)..."

    if [ "$os_choice" -eq 1 ]; then
        log "🔧 Installing pywal via apt..."
        sudo apt install -y python3-pywal >/dev/null 2>>"$LOG_FILE"
    elif [ "$os_choice" -eq 2 ]; then
        log "🔧 Installing pywal via pacman..."
        sudo pacman -S --noconfirm python-pywal >/dev/null 2>>"$LOG_FILE"
    fi

    if ! command -v wal &>/dev/null; then
        log "📦 Installing pywal via pip..."
        if ! command -v pip3 &>/dev/null; then
            pip3 install pywal
        else
            pip install  pywal
        fi
    fi

    if command -v wal &>/dev/null; then
        log "✅ pywal installed successfully."
    else
        log "❌ Failed to install pywal. Please check Python and pip setup."
        log "Or manually link wal."
    fi
}

install_emacs_config() {
  local repo_url="https://github.com/TerryFunggg/emacs-mini.git"
  local target_dir="$HOME/.emacs.d"
  if [ -d "$target_dir" ]; then
      log "✅ Emacs config is on your local"
      return 0
  fi
  log "📥 Cloning Emacs config from GitHub..."
  git clone --quiet "$repo_url" "$target_dir"
  log "✅ Emacs config is on your local. Please run emacs to install emacs packages."
}

install_nvim_config() {
  local repo_url="https://github.com/TerryFunggg/nvim-mini.git"
  local target_dir="$HOME/.config/nvim"
  if [ -d "$target_dir" ]; then
      log "✅ Neo-vim config is on your local"
      return 0
  fi
  log "📥 Cloning neo-vim config from GitHub..."
  git clone --quiet "$repo_url" "$target_dir"
  log "✅ neo-vim config is on your local. Please run nvim to install packages."
}

append_bashrc() {
    grep -qxF 'source ~/.alias' ~/.bashrc || echo 'source ~/.alias' >> ~/.bashrc
}

make_xprofile() {
    if [ ! -f "$xprofile" ]; then
      log "Creating new .xprofile..."
      touch "$xprofile"
      chmod +x "$xprofile"
    fi
}

add_xrandr_config() {

    if [ -f "$xprofile" ] && grep -q "^xrandr " "$xprofile"; then
        echo ""
        log "⚠️  .xprofile already contains xrandr settings:"
        log "Please check the .xprofile. It may break the display"
        return
    fi

    xrandr
    # Prompt for display settings
    read -p "Enter output name (e.g., HDMI-1): " output
    read -p "Enter resolution (e.g., 2560x1440): " resolution
    local line="xrandr --output \"$output\" --mode \"$resolution\""
    echo ""
    echo "$line"
    read -p "❓ Add this to your .xprofile? [y/N]: " confirm

    if [[ "$confirm" == "y" ]]; then
        echo "$line" >> "$xprofile"
        log "✅ Inject xrandr config into xprofile"
    else
        while [[ "$confirm" != "y" ]]; do
            echo "🧾 Type your full xrandr command (e.g. xrandr --output HDMI-1 --mode 1920x1080 --rate 60):"
            read -e -p "> " line
            echo ""
            echo "$line"
            read -p "❓ Add this to your .xprofile? [y/N]: " confirm
        done
        echo "$line" >> "$xprofile"
        log "✅ Inject xrandr config into xprofile"
    fi
}

# ASCII Art Title
echo " /\_/\  /\_/\  /\_/\  /\_/\ "
echo "( o.o )( o.o )( o.o )( o.o )"
echo " > ^ <  > ^ <  > ^ <  > ^ < "
echo " /\_/\   TerryFunggg  /\_/\ "
echo "( o.o )  Dotfiles    ( o.o )"
echo " > ^ <                > ^ < "
echo " /\_/\  /\_/\  /\_/\  /\_/\ "
echo "( o.o )( o.o )( o.o )( o.o )"
echo " > ^ <  > ^ <  > ^ <  > ^ < "
echo "_.-=-._.-=-._.-=-._.-=-._.-="
echo "Author: TerryFung"
echo ""
echo "Dotfile support Linux distro: "
echo "   - Arch"
echo "   - Ubuntu"
echo ""
echo "Install Window Manager:"
echo "   - i3"
echo ""
echo "Install Desktop Environment:"
echo "   - XFCE4"
echo ""
echo "Install Runtime version Manager:"
echo "   - mise"
echo ""
echo "Pre install programming language:"
echo "   - Python(latest)"
echo "   - Nodejs(latest LTS)"
echo ""
echo "Install Font:"
echo "   - Nerd Font"
echo "   - Source Code Pro"
echo ""
echo "Install Editor config:"
echo "   - neo-vim"
echo "   - emacs"
echo ""
echo "🔐 May need root password during installation."
echo "💡 Please check the script before confirm installation."
echo "💡 Make sure you have an active internet connection."
echo "💡 You will see 'Finish' at the end, if not please check /tmp/ty-dotfiles.log"
echo "==========================================="
echo ""

# Confirm to proceed
read -p "🚀 Ready to begin setup? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Setup aborted. Come back when you're ready!"
    exit 0
fi

echo ""
echo "🧩 Choose your operating system:"
echo "   1 = Ubuntu / Debian"
echo "   2 = Arch / Manjaro"
read -p "Enter your choice [1/2]: " os_choice

case "$os_choice" in
    1 )
        log "Got it! You are using debin or Ubuntu."
        ;;
    2 )
        log "Okay! I use Arch btw."
        ;;
    * )
        log "Unsupport OS. Stop dotfile install."
        exit 1
        ;;
esac

install_tools $os_choice
install_config_files
install_mise
install_wal
install_font

echo -e "\n$(cat <<'EOF'
 _____      _
| ____|_  _| |_ _ __ __ _
|  _| \ \/ / __| '__/ _` |
| |___ >  <| |_| | | (_| |
|_____/_/\_\\__|_|  \__,_|

EOF
)\n"

append_bashrc
make_xprofile
add_xrandr_config
install_emacs_config
install_nvim_config

# add my perfer theme color(you can check this on ~/bin/wal-theme)
grep -qxF 'wal-theme' $xprofile || echo 'wal-theme' >> $xprofile
log "✅ Inject 'wal-theme' into xprofile"

echo ""
log "Finish! Happy Hacking!"

