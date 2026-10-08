# Hyprland dotfiles

Personal Arch Linux desktop configuration for Hyprland, Kitty, Fastfetch, Wofi,
Hyprpaper, Hypridle, Hyprlock, Dunst, and Quickshell. It includes the
ink-wash wallpaper used by the desktop theme.

## Repository layout

```text
hyprland-dotfiles/
├── assets/
│   └── wallpapers/                  # Wallpaper collection for the picker
├── bin/
│   ├── hypr-theme-menu               # Fixed-theme chooser
│   ├── hypr-theme-select             # Applies a named fixed theme profile
│   └── hypr-wallpaper-switch         # Applies and persists a selected wallpaper
├── config/
│   ├── dunst/
│   │   └── dunstrc                 # Fixed-profile notification colors
│   ├── fastfetch/
│   │   └── config.jsonc             # System-information layout
│   ├── gtk-3.0/ and gtk-4.0/        # Dynamic color overrides for GTK apps
│   ├── hypr/
│   │   ├── colors.lua               # Fixed Hyprland profile palette
│   │   ├── hypridle.conf            # Idle, lock, and suspend timers
│   │   ├── hyprland.lua             # Monitors, keybinds, layout, borders
│   │   ├── hyprlock.conf            # Lock-screen appearance
│   │   ├── hyprlock-colors.conf     # Generated lock-screen palette
│   │   └── hyprpaper.conf           # Wallpaper configuration
│   ├── kitty/
│   │   ├── dynamic.conf             # Fixed terminal palette
│   │   └── kitty.conf               # Terminal layout and palette import
│   ├── quickshell/
│   │   ├── DynamicTheme.qml         # Fixed shell profile palette
│   │   └── shell.qml                # Top-left menu and wallpaper manager
│   ├── themes/templates/             # Shared fixed-profile output templates
│   ├── vim/                         # Shared Kitty-palette loader for Vim/Neovim
│   ├── nvim/
│   │   └── init.lua                 # Wallpaper-aware BufferLine tabs
│   └── wofi/
│       ├── config                   # Text-only application runner behavior
│       ├── colors.css               # Fixed launcher palette
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

## Fixed rice profiles

Wallpaper selection and colors are deliberately independent: choosing a wallpaper
never generates or guesses a palette. The current fixed profiles are:

- `alpine` — black terminals with warm sepia text, based on the Alpine reference.
- `ink-wash` — parchment terminals with dark ink text, based on the ink-wash reference.
- `gothic-rose` — near-black terminals with ivory text and dusty rose accents.

Press `Super + Shift + T` to choose a profile, or apply one directly:

```sh
hypr-theme-select alpine
hypr-theme-select ink-wash
hypr-theme-select gothic-rose
```

Every profile updates Hyprland, Kitty, Wofi, Quickshell, Hyprlock, Dunst, GTK,
and the palette read by Vim/Neovim. Quickshell itself—including the top bar and
wallpaper manager—remains enabled.

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

The script installs each configuration file into `~/.config` and the wallpaper into
`~/Pictures`. Before it overwrites a changed file, it saves the previous version in
`~/.config-backups/hyprland-dotfiles-<timestamp>/`.

After installation, reload Hyprland with `Super + Shift + R`, then restart
Hyprpaper or log out and back in.

## Update the backup

Copy any changes you want to retain into this repository, then commit and push:

```sh
git add .
git commit -m "Update desktop configuration"
git push
```
