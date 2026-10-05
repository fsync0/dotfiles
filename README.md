# Hyprland dotfiles

Personal Arch Linux desktop configuration for Hyprland, Kitty, Fastfetch, Wofi,
Hyprpaper, Hypridle, Hyprlock, Dunst, Quickshell, and Matugen. It includes the
ink-wash wallpaper used by the desktop theme.

## Repository layout

```text
hyprland-dotfiles/
├── assets/
│   └── wallpapers/                  # Wallpaper collection for the picker
├── bin/
│   └── hypr-wallpaper-switch        # Applies and persists a selected wallpaper
├── config/
│   ├── dunst/
│   │   └── dunstrc                 # Wallpaper-derived notification colors
│   ├── fastfetch/
│   │   └── config.jsonc             # System-information layout
│   ├── gtk-3.0/ and gtk-4.0/        # Dynamic color overrides for GTK apps
│   ├── hypr/
│   │   ├── colors.lua               # Generated Hyprland border palette
│   │   ├── hypridle.conf            # Idle, lock, and suspend timers
│   │   ├── hyprland.lua             # Monitors, keybinds, layout, borders
│   │   ├── hyprlock.conf            # Lock-screen appearance
│   │   ├── hyprlock-colors.conf     # Generated lock-screen palette
│   │   └── hyprpaper.conf           # Wallpaper configuration
│   ├── kitty/
│   │   ├── dynamic.conf             # Generated terminal palette
│   │   └── kitty.conf               # Terminal layout and generated palette import
│   ├── matugen/
│   │   ├── config.toml              # Palette generator settings
│   │   ├── presets/                  # Exact palette per wallpaper-XX ID
│   │   └── templates/               # Sources for every generated color file
│   ├── quickshell/
│   │   ├── DynamicTheme.qml         # Generated shell color palette
│   │   └── shell.qml                # Top-left menu and wallpaper manager
│   ├── vim/                         # Shared Kitty-palette loader for Vim/Neovim
│   ├── nvim/
│   │   └── init.vim                 # Loads the shared wallpaper theme
│   └── wofi/
│       ├── config                   # Text-only application runner behavior
│       ├── colors.css               # Generated launcher palette
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

## Wallpaper-driven colors

Each wallpaper has a stable ID such as `wallpaper-01.jpg`; its exact matching
palette lives in `config/matugen/presets/wallpaper-01/`. Selecting a known
wallpaper restores its checked-in palette, which makes its colors repeatable
across reinstalls. A newly added image is analyzed once with Matugen and receives
its own preset folder automatically.

The shared palette is applied to Hyprland, Kitty, Wofi, Quickshell, Hyprlock,
Dunst, GTK, and Vim/Neovim. Vim and Neovim read Kitty's current generated
palette at startup and whenever they regain focus, so an already-open editor
updates after switching wallpaper. Existing GUI apps may need reopening to pick
up new GTK colors; the other components reload automatically. You can regenerate
the active palette manually with:

```sh
matugen image "$(sed -n 's/^    path = //p' ~/.config/hypr/hyprpaper.conf)"
```

## Restore on a new machine

```sh
git clone https://github.com/fsync0/dotfiles.git
cd dotfiles
./setup.sh --install-packages
```

`--install-packages` installs the needed Arch packages—including Matugen—with
`pacman`. Omit it if they are already installed:

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
