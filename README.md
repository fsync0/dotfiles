# Hyprland dotfiles

Personal Arch Linux desktop configuration for Hyprland, Kitty, Fastfetch, Wofi,
Hyprpaper, Hypridle, Hyprlock, Dunst, Quickshell, and Zsh. It includes an
Alpine desktop palette, a translucent blue-gray Kitty terminal, and a wallpaper picker.

## Repository layout

```text
hyprland-dotfiles/
├── assets/
│   └── wallpapers/                  # Wallpaper collection for the picker
├── bin/
│   └── hypr-wallpaper-switch         # Applies and persists a selected wallpaper
├── config/
│   ├── dunst/
│   │   └── dunstrc                 # Alpine notification colors
│   ├── fastfetch/
│   │   └── config.jsonc             # System-information layout
│   ├── gtk-3.0/ and gtk-4.0/        # Alpine color overrides for GTK apps
│   ├── hypr/
│   │   ├── colors.lua               # Alpine Hyprland palette
│   │   ├── hypridle.conf            # Idle, lock, and suspend timers
│   │   ├── hyprland.lua             # Monitors, keybinds, layout, borders
│   │   ├── hyprlock.conf            # Lock-screen appearance
│   │   ├── hyprlock-colors.conf     # Alpine lock-screen palette
│   │   └── hyprpaper.conf           # Wallpaper configuration
│   ├── kitty/
│   │   ├── dynamic.conf             # Blue-gray terminal palette
│   │   └── kitty.conf               # Translucent terminal layout and palette import
│   ├── quickshell/
│   │   ├── DynamicTheme.qml         # Alpine shell palette
│   │   └── shell.qml                # Top-left menu and wallpaper manager
│   ├── vim/                         # Shared Kitty-palette loader for Vim/Neovim
│   ├── nvim/
│   │   └── init.lua                 # Wallpaper-aware BufferLine tabs
│   ├── zsh/
│   │   ├── p10k.zsh                 # Powerlevel10k prompt layout
│   │   └── zshrc                    # Zsh startup configuration
│   └── wofi/
│       ├── config                   # Text-only application runner behavior
│       ├── colors.css               # Alpine launcher palette
│       └── style.css                # Application runner appearance
├── .gitignore
├── README.md
└── setup.sh                         # Idempotent installer and backup helper
```

`setup.sh` maps `config/<name>/...` to `~/.config/<name>/...`, installs the
wallpaper collection into `~/Pictures/Wallpapers/`, and installs the wallpaper
switching helper in `~/.local/bin/`. The Hyprpaper template automatically replaces
its home-directory placeholder during installation, so it works for a different
Linux username too.

The Quickshell workspace menu appears in the top-left. Press `Super + Shift + W`
to open the Walt-inspired wallpaper manager. It automatically scans
`~/Pictures/Wallpapers/`, so add PNG, JPG, JPEG, or WebP files there to make them
available. Use `↑/↓` or `j/k` to choose an image, `Enter` to apply it, `r` for a
random wallpaper, and `Esc` to close. Double-clicking an entry also applies it.

## Desktop and terminal themes

The desktop uses one fixed Alpine palette: black surfaces, warm sepia text, and
muted earth-tone accents. Kitty deliberately uses a blue-gray translucent palette,
with square corners, a block cursor, and a Powerlevel10k prompt. Wallpaper selection
never changes either palette.

## Restore on a new machine

```sh
git clone https://github.com/fsync0/dotfiles.git
cd dotfiles
./setup.sh --install-packages
```

`--install-packages` installs the needed Arch packages with `pacman`. Omit it if
they are already installed:

```sh
./setup.sh
```

The script installs each configuration file into `~/.config`, the Zsh files into
your home directory, and the wallpaper into `~/Pictures`. It also downloads
Powerlevel10k to `~/.local/share/powerlevel10k`. Before it overwrites a changed file,
it saves the previous version in `~/.config-backups/hyprland-dotfiles-<timestamp>/`.

After installation, reload Hyprland with `Super + Shift + R`, then restart
Hyprpaper or log out and back in.

## Update the backup

Copy any changes you want to retain into this repository, then commit and push:

```sh
git add .
git commit -m "Update desktop configuration"
git push
```
