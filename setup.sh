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
        hyprland hyprpaper hypridle hyprlock kitty fastfetch wofi quickshell neovim \
        dunst matugen networkmanager zathura zathura-pdf-poppler
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

    [[ "$source" == *"hypr-wallpaper-switch" ]] && mode="0755"

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
install_file "$repo_dir/config/matugen/config.toml" "$home_dir/.config/matugen/config.toml"
install_file "$repo_dir/config/matugen/templates/hypr-colors.lua" "$home_dir/.config/matugen/templates/hypr-colors.lua"
install_file "$repo_dir/config/matugen/templates/kitty.conf" "$home_dir/.config/matugen/templates/kitty.conf"
install_file "$repo_dir/config/matugen/templates/wofi.css" "$home_dir/.config/matugen/templates/wofi.css"
install_file "$repo_dir/config/matugen/templates/DynamicTheme.qml" "$home_dir/.config/matugen/templates/DynamicTheme.qml"
install_file "$repo_dir/config/matugen/templates/hyprlock-colors.conf" "$home_dir/.config/matugen/templates/hyprlock-colors.conf"
install_file "$repo_dir/config/matugen/templates/dunstrc" "$home_dir/.config/matugen/templates/dunstrc"
install_file "$repo_dir/config/matugen/templates/gtk-colors.css" "$home_dir/.config/matugen/templates/gtk-colors.css"

# Each numbered wallpaper has a checked-in, exact palette. Keep the files together
# so a fresh install gets identical colors without having to regenerate them.
while IFS= read -r -d '' preset_file; do
    preset_relative="${preset_file#"$repo_dir/config/matugen/presets/"}"
    install_file "$preset_file" "$home_dir/.config/matugen/presets/$preset_relative"
done < <(find "$repo_dir/config/matugen/presets" -type f -print0)

install_file "$repo_dir/bin/hypr-wallpaper-switch" "$home_dir/.local/bin/hypr-wallpaper-switch"

for wallpaper in "$repo_dir"/assets/wallpapers/*; do
    [[ -f "$wallpaper" ]] || continue
    install_file "$wallpaper" "$home_dir/Pictures/Wallpapers/$(basename -- "$wallpaper")"
done

if "$made_backup"; then
    printf 'Previous files backed up to %s\n' "$backup_root"
fi

printf 'Done. The wallpaper switcher now refreshes the Matugen palette automatically.\n'
