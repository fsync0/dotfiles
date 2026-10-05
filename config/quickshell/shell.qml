//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: root

    property bool pickerOpen: false
    property int selectedIndex: 0
    property var wallpapers: []
    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaperDirectory: home + "/Pictures/Wallpapers"

    function applyWallpaper(path) {
        Quickshell.execDetached([home + "/.local/bin/hypr-wallpaper-switch", path])
        pickerOpen = false
    }

    function refreshWallpapers() {
        wallpaperScanner.running = false
        wallpaperScanner.running = true
    }

    onPickerOpenChanged: if (pickerOpen) refreshWallpapers()

    Process {
        id: wallpaperScanner
        command: ["find", root.wallpaperDirectory, "-maxdepth", "1", "-type", "f", "-printf", "%p\\n"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                const paths = output.length === 0 ? [] : output.split("\n")
                root.wallpapers = paths
                    .filter(path => /\.(png|jpe?g|webp)$/i.test(path))
                    .sort()
                    .map(path => ({
                        path: path,
                        name: path.split("/").pop()
                            .replace(/^\d+-/, "")
                            .replace(/\.[^.]+$/, "")
                            .replace(/[-_]/g, " ")
                    }))
                root.selectedIndex = Math.min(root.selectedIndex, Math.max(0, root.wallpapers.length - 1))
            }
        }
    }

    GlobalShortcut {
        name: "wallpaper-picker"
        description: "Open the wallpaper picker"
        onPressed: root.pickerOpen = !root.pickerOpen
    }

    // Compact workspace menu inspired by the supplied reference.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            implicitHeight: 31
            color: "transparent"
            focusable: false
            exclusiveZone: 7

            anchors {
                top: true
                left: true
                right: true
            }

            Row {
                x: 12
                height: parent.height - 3
                spacing: 8

                Text {
                    width: 16
                    height: parent.height
                    text: "󰣇"
                    color: "#748078"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Repeater {
                    model: Hyprland.workspaces

                    Item {
                        required property var modelData
                        readonly property int workspaceNumber: Number(modelData.name)
                        readonly property bool inMenu: workspaceNumber >= 1 && workspaceNumber <= 5

                        visible: inMenu
                        width: inMenu ? 14 : 0
                        height: parent.height

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: modelData.focused ? "#e7bd68" : "#748078"
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: modelData.focused
                            font.pixelSize: 13
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 10
                            height: 2
                            color: "#e7bd68"
                            visible: modelData.focused
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.activate()
                        }
                    }
                }

                Text {
                    width: 14
                    height: parent.height
                    text: "~"
                    color: "#748078"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Fullscreen wallpaper carousel: center card, dimmed side previews, gold active state.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.pickerOpen
            color: "transparent"
            focusable: true
            exclusiveZone: 0

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            FocusScope {
                anchors.fill: parent
                focus: root.pickerOpen

                Rectangle {
                    anchors.fill: parent
                    color: "#0b1012df"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.pickerOpen = false
                    }
                }

                Item {
                    id: carousel
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 120, 1460)
                    height: Math.min(parent.height - 160, 610)
                    clip: true

                    Repeater {
                        model: root.wallpapers

                        Item {
                            required property var modelData
                            readonly property int offset: index - root.selectedIndex
                            readonly property bool selected: offset === 0

                            visible: Math.abs(offset) <= 2
                            enabled: visible
                            width: selected ? Math.min(carousel.width * 0.62, 900) : 190
                            height: selected ? carousel.height - 10 : carousel.height - 66
                            x: carousel.width / 2 - width / 2 + offset * (carousel.width * 0.36)
                            y: selected ? 5 : 33
                            z: selected ? 10 : 5 - Math.abs(offset)
                            opacity: selected ? 1 : 0.72

                            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration: 140 } }

                            Rectangle {
                                anchors.fill: parent
                                color: "#111827"
                                border.width: selected ? 4 : 2
                                border.color: selected ? "#e0a323" : "#d8d0ad"

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: parent.border.width
                                    source: "file://" + modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                Rectangle {
                                    visible: selected
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: 16
                                    anchors.rightMargin: 16
                                    width: 80
                                    height: 34
                                    radius: 18
                                    color: "#dfa324"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "ACTIVE"
                                        color: "#1a1d1d"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedIndex = index
                                    root.applyWallpaper(modelData.path)
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.wallpapers.length === 0
                        text: "No images in ~/Pictures/Wallpapers"
                        color: "#d8d0ad"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.pickerOpen = false
                    } else if (event.key === Qt.Key_Left) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                    } else if (event.key === Qt.Key_Right) {
                        root.selectedIndex = Math.min(root.wallpapers.length - 1, root.selectedIndex + 1)
                    } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.wallpapers.length > 0) {
                        root.applyWallpaper(root.wallpapers[root.selectedIndex].path)
                    } else {
                        return
                    }
                    event.accepted = true
                }
            }
        }
    }
}
