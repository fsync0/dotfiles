import QtQuick

QtObject {
    readonly property string background: "{{colors.surface_container_lowest.dark.hex}}"
    readonly property string surface: "{{colors.surface_container.dark.hex}}"
    readonly property string surfaceHigh: "{{colors.surface_container_high.dark.hex}}"
    readonly property string foreground: "{{colors.on_surface.dark.hex}}"
    readonly property string muted: "{{colors.on_surface_variant.dark.hex}}"
    readonly property string primary: "{{colors.primary.dark.hex}}"
    readonly property string primaryContainer: "{{colors.primary_container.dark.hex}}"
    readonly property string primaryContainerText: "{{colors.on_primary_container.dark.hex}}"
    readonly property string secondary: "{{colors.secondary.dark.hex}}"
    readonly property string tertiary: "{{colors.tertiary.dark.hex}}"
    readonly property string outline: "{{colors.outline.dark.hex}}"
    readonly property string outlineVariant: "{{colors.outline_variant.dark.hex}}"
    readonly property string overlay: "#{{colors.scrim.dark.hex_stripped}}d9"
}
