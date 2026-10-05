# Hyprland dotfiles

Personal Arch Linux desktop configuration for Hyprland, Kitty, Fastfetch, Wofi,
Hyprpaper, Hypridle, Hyprlock, and Quickshell. It includes the ink-wash wallpaper
used by the desktop theme.

## Repository layout

```text
hyprland-dotfiles/
├── assets/
│   └── wallpapers/                  # Wallpaper collection for the picker
├── bin/
│   └── hypr-wallpaper-switch        # Applies and persists a selected wallpaper
├── config/
│   ├── fastfetch/
│   │   └── config.jsonc             # System-information layout
│   ├── hypr/
│   │   ├── hypridle.conf            # Idle, lock, and suspend timers
│   │   ├── hyprland.lua             # Monitors, keybinds, layout, borders
│   │   ├── hyprlock.conf            # Lock-screen appearance
│   │   └── hyprpaper.conf           # Wallpaper configuration
│   ├── kitty/
│   │   └── kitty.conf               # Terminal colors, padding, borders
│   ├── quickshell/
│   │   └── shell.qml                # Optional shell/panel definition
│   └── wofi/
│       ├── config                   # Text-only application runner behavior
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
to open the wallpaper carousel. It automatically scans `~/Pictures/Wallpapers/`,
so add PNG, JPG, JPEG, or WebP files there to make them available. Click a preview
to apply it, or use the arrow keys followed by `Enter`; press `Esc` to cancel.

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
