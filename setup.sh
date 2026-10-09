#!/usr/bin/env bash
# Install the Hyprland desktop configuration from this repository.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
home_dir="${HOME:?HOME must be set}"
install_packages=false

for argument in "$@"; do
    case "$argument" in
        --install-packages) install_packages=true ;;
        --help|-h)
            printf 'Usage: %s [--install-packages]\n' "$0"
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$argument" >&2
            exit 1
            ;;
    esac
done

if "$install_packages"; then
    sudo pacman -S --needed --noconfirm \
        hyprland hyprpaper hypridle hyprlock kitty fastfetch wofi quickshell neovim vim zsh tmux grim slurp \
        networkmanager bluez bluez-utils python-textual zathura zathura-pdf-poppler curl unzip fontconfig git fzf ripgrep \
        pyright gopls rust-analyzer clang
fi

backup_root="$home_dir/.config-backups/hyprland-dotfiles-$(date +%Y%m%d-%H%M%S)"
made_backup=false

backup_target() {
    local target="$1"
    local relative_path="${target#"$home_dir"/}"

    if [[ -e "$target" ]]; then
        mkdir -p "$backup_root/$(dirname -- "$relative_path")"
        cp -a -- "$target" "$backup_root/$relative_path"
        made_backup=true
    fi
}

install_file() {
    local source="$1"
    local target="$2"
    local temporary_file=""
    local mode="0644"

    [[ "$source" == *"hypr-wallpaper-switch" || "$source" == *"/bin/connect" ]] && mode="0755"

    if [[ "$source" == *"hyprpaper.conf" ]]; then
        temporary_file="$(mktemp)"
        sed "s|__HOME__|$home_dir|g" "$source" > "$temporary_file"
        source="$temporary_file"
    fi

    mkdir -p "$(dirname -- "$target")"
    if [[ ! -f "$target" ]] || ! cmp -s -- "$source" "$target"; then
        backup_target "$target"
        install -m "$mode" -- "$source" "$target"
        printf 'Installed %s\n' "${target#"$home_dir"/}"
    fi

    [[ -z "$temporary_file" ]] || rm -f -- "$temporary_file"
}

install_google_sans_code() {
    local target="$home_dir/.local/share/fonts/GoogleSansCode"
    local font="$target/GoogleSansCodeNerdFontMono-Regular.ttf"
    local archive=""
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/GoogleSansCode.zip"

    if [[ -r "$font" ]]; then
        fc-cache -f "$target"
        return
    fi

    command -v curl >/dev/null 2>&1 || {
        printf 'curl is required to install Google Sans Code Nerd Font.\n' >&2
        return 1
    }
    command -v unzip >/dev/null 2>&1 || {
        printf 'unzip is required to install Google Sans Code Nerd Font.\n' >&2
        return 1
    }
    command -v fc-cache >/dev/null 2>&1 || {
        printf 'fontconfig is required to install Google Sans Code Nerd Font.\n' >&2
        return 1
    }

    archive="$(mktemp)"
    curl --fail --location --output "$archive" "$url"
    mkdir -p "$target"
    unzip -q -o "$archive" -d "$target"
    rm -f -- "$archive"
    fc-cache -f "$target"
}

install_powerlevel10k() {
    local target="$home_dir/.local/share/powerlevel10k"

    [[ -r "$target/powerlevel10k.zsh-theme" ]] && return

    if [[ -e "$target" ]]; then
        printf 'Powerlevel10k target exists but is incomplete: %s\n' "$target" >&2
        return 1
    fi

    command -v git >/dev/null 2>&1 || {
        printf 'Git is required to install Powerlevel10k.\n' >&2
        return 1
    }

    mkdir -p "$(dirname -- "$target")"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
}

install_tmux_plugin_manager() {
    local target="$home_dir/.config/tmux/plugins/tpm"

    [[ -x "$target/tpm" ]] && return

    if [[ -e "$target" ]]; then
        printf 'TPM target exists but is incomplete: %s\n' "$target" >&2
        return 1
    fi

    command -v git >/dev/null 2>&1 || {
        printf 'Git is required to install TPM.\n' >&2
        return 1
    }

    mkdir -p "$(dirname -- "$target")"
    git clone --depth=1 https://github.com/tmux-plugins/tpm.git "$target"
}

install_vim_startify() {
    local target="$home_dir/.vim/pack/plugins/start/vim-startify"

    [[ -r "$target/plugin/startify.vim" ]] && return

    if [[ -e "$target" ]]; then
        printf 'vim-startify target exists but is incomplete: %s\n' "$target" >&2
        return 1
    fi

    command -v git >/dev/null 2>&1 || {
        printf 'Git is required to install vim-startify.\n' >&2
        return 1
    }

    mkdir -p "$(dirname -- "$target")"
    git clone --depth=1 https://github.com/mhinz/vim-startify.git "$target"
}

install_vim_lsp_plugins() {
    local plugin_root="$home_dir/.vim/pack/plugins/start"
    local names=("vim-lsp" "asyncomplete.vim" "asyncomplete-lsp.vim")
    local sources=(
        "https://github.com/prabirshrestha/vim-lsp.git"
        "https://github.com/prabirshrestha/asyncomplete.vim.git"
        "https://github.com/prabirshrestha/asyncomplete-lsp.vim.git"
    )
    local plugin_files=("plugin/lsp.vim" "plugin/asyncomplete.vim" "plugin/asyncomplete-lsp.vim")
    local index=""
    local target=""

    command -v git >/dev/null 2>&1 || {
        printf 'Git is required to install Vim LSP plugins.\n' >&2
        return 1
    }

    mkdir -p "$plugin_root"
    for index in "${!names[@]}"; do
        target="$plugin_root/${names[$index]}"
        [[ -r "$target/${plugin_files[$index]}" ]] && continue

        if [[ -e "$target" ]]; then
            printf 'Vim plugin target exists but is incomplete: %s\n' "$target" >&2
            return 1
        fi

        git clone --depth=1 "${sources[$index]}" "$target"
    done
}

install_vim_productivity_plugins() {
    local plugin_root="$home_dir/.vim/pack/plugins/start"
    local names=("vim-tmux-navigator" "vim-fugitive" "fzf.vim" "undotree" "vim-which-key")
    local sources=(
        "https://github.com/christoomey/vim-tmux-navigator.git"
        "https://github.com/tpope/vim-fugitive.git"
        "https://github.com/junegunn/fzf.vim.git"
        "https://github.com/mbbill/undotree.git"
        "https://github.com/liuchengxu/vim-which-key.git"
    )
    local plugin_files=("plugin/tmux_navigator.vim" "plugin/fugitive.vim" "plugin/fzf.vim" "plugin/undotree.vim" "plugin/which_key.vim")
    local index=""
    local target=""

    command -v git >/dev/null 2>&1 || {
        printf 'Git is required to install Vim productivity plugins.\n' >&2
        return 1
    }

    mkdir -p "$plugin_root"
    for index in "${!names[@]}"; do
        target="$plugin_root/${names[$index]}"
        [[ -r "$target/${plugin_files[$index]}" ]] && continue

        if [[ -e "$target" ]]; then
            printf 'Vim plugin target exists but is incomplete: %s\n' "$target" >&2
            return 1
        fi

        git clone --depth=1 "${sources[$index]}" "$target"
    done
}

install_file "$repo_dir/config/hypr/hyprland.lua" "$home_dir/.config/hypr/hyprland.lua"
install_file "$repo_dir/config/hypr/colors.lua" "$home_dir/.config/hypr/colors.lua"
install_file "$repo_dir/config/hypr/hypridle.conf" "$home_dir/.config/hypr/hypridle.conf"
install_file "$repo_dir/config/hypr/hyprlock.conf" "$home_dir/.config/hypr/hyprlock.conf"
install_file "$repo_dir/config/hypr/hyprlock-colors.conf" "$home_dir/.config/hypr/hyprlock-colors.conf"
install_file "$repo_dir/config/hypr/hyprpaper.conf" "$home_dir/.config/hypr/hyprpaper.conf"
install_file "$repo_dir/config/kitty/kitty.conf" "$home_dir/.config/kitty/kitty.conf"
install_file "$repo_dir/config/kitty/dynamic.conf" "$home_dir/.config/kitty/dynamic.conf"
install_file "$repo_dir/config/fastfetch/config.jsonc" "$home_dir/.config/fastfetch/config.jsonc"
install_file "$repo_dir/config/wofi/config" "$home_dir/.config/wofi/config"
install_file "$repo_dir/config/wofi/style.css" "$home_dir/.config/wofi/style.css"
install_file "$repo_dir/config/wofi/colors.css" "$home_dir/.config/wofi/colors.css"
install_file "$repo_dir/config/quickshell/shell.qml" "$home_dir/.config/quickshell/shell.qml"
install_file "$repo_dir/config/quickshell/DynamicTheme.qml" "$home_dir/.config/quickshell/DynamicTheme.qml"
install_file "$repo_dir/config/quickshell/NotificationCenter.qml" "$home_dir/.config/quickshell/NotificationCenter.qml"
install_file "$repo_dir/config/quickshell/NotificationPopup.qml" "$home_dir/.config/quickshell/NotificationPopup.qml"
install_file "$repo_dir/config/dunst/dunstrc" "$home_dir/.config/dunst/dunstrc"
install_file "$repo_dir/config/gtk-3.0/gtk.css" "$home_dir/.config/gtk-3.0/gtk.css"
install_file "$repo_dir/config/gtk-3.0/matugen-colors.css" "$home_dir/.config/gtk-3.0/matugen-colors.css"
install_file "$repo_dir/config/gtk-3.0/settings.ini" "$home_dir/.config/gtk-3.0/settings.ini"
install_file "$repo_dir/config/gtk-4.0/gtk.css" "$home_dir/.config/gtk-4.0/gtk.css"
install_file "$repo_dir/config/gtk-4.0/matugen-colors.css" "$home_dir/.config/gtk-4.0/matugen-colors.css"
install_file "$repo_dir/config/gtk-4.0/settings.ini" "$home_dir/.config/gtk-4.0/settings.ini"
install_file "$repo_dir/config/vim/wallpaper-theme.vim" "$home_dir/.config/vim/wallpaper-theme.vim"
install_file "$repo_dir/config/vim/vimrc" "$home_dir/.vimrc"
install_file "$repo_dir/config/nvim/init.lua" "$home_dir/.config/nvim/init.lua"
install_file "$repo_dir/config/nvim/lazy-lock.json" "$home_dir/.config/nvim/lazy-lock.json"
install_file "$repo_dir/config/nvim/lazyvim.json" "$home_dir/.config/nvim/lazyvim.json"
install_file "$repo_dir/config/nvim/lua/config/autocmds.lua" "$home_dir/.config/nvim/lua/config/autocmds.lua"
install_file "$repo_dir/config/nvim/lua/config/keymaps.lua" "$home_dir/.config/nvim/lua/config/keymaps.lua"
install_file "$repo_dir/config/nvim/lua/config/lazy.lua" "$home_dir/.config/nvim/lua/config/lazy.lua"
install_file "$repo_dir/config/nvim/lua/config/options.lua" "$home_dir/.config/nvim/lua/config/options.lua"
install_file "$repo_dir/config/nvim/lua/craftzdog/discipline.lua" "$home_dir/.config/nvim/lua/craftzdog/discipline.lua"
install_file "$repo_dir/config/nvim/lua/craftzdog/hsl.lua" "$home_dir/.config/nvim/lua/craftzdog/hsl.lua"
install_file "$repo_dir/config/nvim/lua/craftzdog/lsp.lua" "$home_dir/.config/nvim/lua/craftzdog/lsp.lua"
install_file "$repo_dir/config/nvim/lua/plugins/coding.lua" "$home_dir/.config/nvim/lua/plugins/coding.lua"
install_file "$repo_dir/config/nvim/lua/plugins/colorscheme.lua" "$home_dir/.config/nvim/lua/plugins/colorscheme.lua"
install_file "$repo_dir/config/nvim/lua/plugins/editor.lua" "$home_dir/.config/nvim/lua/plugins/editor.lua"
install_file "$repo_dir/config/nvim/lua/plugins/lsp.lua" "$home_dir/.config/nvim/lua/plugins/lsp.lua"
install_file "$repo_dir/config/nvim/lua/plugins/treesitter.lua" "$home_dir/.config/nvim/lua/plugins/treesitter.lua"
install_file "$repo_dir/config/nvim/lua/plugins/ui.lua" "$home_dir/.config/nvim/lua/plugins/ui.lua"
install_file "$repo_dir/config/nvim/lua/util/debug.lua" "$home_dir/.config/nvim/lua/util/debug.lua"
install_file "$repo_dir/config/tmux/tmux.conf" "$home_dir/.config/tmux/tmux.conf"
install_file "$repo_dir/config/tmux/theme.conf" "$home_dir/.config/tmux/theme.conf"
install_file "$repo_dir/config/tmux/statusline.conf" "$home_dir/.config/tmux/statusline.conf"
install_file "$repo_dir/config/tmux/utility.conf" "$home_dir/.config/tmux/utility.conf"
install_file "$repo_dir/config/tmux/macos.conf" "$home_dir/.config/tmux/macos.conf"
install_file "$repo_dir/config/zsh/zshrc" "$home_dir/.zshrc"
install_file "$repo_dir/config/zsh/p10k.zsh" "$home_dir/.p10k.zsh"
install_file "$repo_dir/bin/hypr-wallpaper-switch" "$home_dir/.local/bin/hypr-wallpaper-switch"
install_file "$repo_dir/bin/connect" "$home_dir/.local/bin/connect"
install_file "$repo_dir/bin/connect.tcss" "$home_dir/.local/bin/connect.tcss"
install_google_sans_code
install_powerlevel10k
install_tmux_plugin_manager
install_vim_startify
install_vim_lsp_plugins
install_vim_productivity_plugins

for wallpaper in "$repo_dir"/assets/wallpapers/*; do
    [[ -f "$wallpaper" ]] || continue
    install_file "$wallpaper" "$home_dir/Pictures/Wallpapers/$(basename -- "$wallpaper")"
done

if "$made_backup"; then
    printf 'Previous files backed up to %s\n' "$backup_root"
fi

printf 'Done. Desktop and terminal palettes are fixed independently.\n'
