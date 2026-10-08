//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower

ShellRoot {
    id: root

    property bool pickerOpen: false
    property int selectedIndex: 0
    property var wallpapers: []
    property string currentWallpaperPath: ""
    property string metaResolution: "Loading..."
    property string metaSize: "Loading..."
    property string metaFormat: "Loading..."
    property string metaModified: "Loading..."
    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaperDirectory: home + "/Pictures/Wallpapers"

    DynamicTheme { id: theme }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function selectedWallpaper() {
        return wallpapers.length > 0 ? wallpapers[selectedIndex] : null
    }

    function applyWallpaper(path) {
        currentWallpaperPath = path
        Quickshell.execDetached([home + "/.local/bin/hypr-wallpaper-switch", path])
        pickerOpen = false
    }

    function refreshWallpapers() {
        wallpaperScanner.running = false
        wallpaperScanner.running = true
    }

    function refreshMetadata() {
        const wallpaper = selectedWallpaper()
        if (!wallpaper)
            return

        metaResolution = "Loading..."
        metaSize = "Loading..."
        metaFormat = "Loading..."
        metaModified = "Loading..."
        metadataScanner.exec(["/usr/bin/sh", "-c", "/usr/bin/file -b -- \"$1\"; /usr/bin/stat -c '%s|%y' -- \"$1\"", "metadata", wallpaper.path])
    }

    function formatFileSize(bytes) {
        const size = Number(bytes)
        if (!Number.isFinite(size) || size < 0)
            return "Unknown"

        const units = ["B", "KB", "MB", "GB"]
        let value = size
        let unit = 0
        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024
            unit += 1
        }
        return (unit === 0 ? value : value.toFixed(1)) + " " + units[unit]
    }

    onPickerOpenChanged: if (pickerOpen) refreshWallpapers()
    onSelectedIndexChanged: {
        refreshMetadata()
        if (pickerOpen && wallpapers.length > 0)
            wallpaperList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    Process {
        id: activeWallpaperScanner
        command: ["sh", "-c", "sed -n 's/^    path = //p' \"$HOME/.config/hypr/hyprpaper.conf\" | head -n 1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.currentWallpaperPath = this.text.trim()
                root.refreshWallpapers()
            }
        }
    }

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

                const activeIndex = root.wallpapers.findIndex(item => item.path === root.currentWallpaperPath)
                root.selectedIndex = activeIndex >= 0 ? activeIndex : 0
                root.refreshMetadata()
            }
        }
    }

    Process {
        id: metadataScanner

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                const description = lines[0] || ""
                const fields = (lines[1] || "").split("|")
                const dimensions = description.match(/(\d+)\s*x\s*(\d+)/g)
                const resolution = dimensions && dimensions.length > 0
                    ? dimensions[dimensions.length - 1].match(/(\d+)\s*x\s*(\d+)/)
                    : null
                const format = description.match(/^([A-Za-z]+)/)

                root.metaResolution = resolution ? resolution[1] + "×" + resolution[2] : "Unknown"
                root.metaSize = root.formatFileSize(fields[0])
                root.metaFormat = format ? format[1].toUpperCase() : "Unknown"
                root.metaModified = fields[1] ? fields[1].replace(/\..*$/, "") : "Unknown"
            }
        }
    }

    GlobalShortcut {
        name: "wallpaper-picker"
        description: "Open the wallpaper picker"
        onPressed: root.pickerOpen = !root.pickerOpen
    }

    // Compact workspace menu.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            implicitHeight: 31
            color: "transparent"
            focusable: false
            // Reserve an extra 12 px below the panel before Hyprland places windows.
            exclusiveZone: 14
            margins {
                top: 4
            }

            anchors {
                top: true
                left: true
                right: true
            }

            Row {
                // Align the workspace list with Hyprland's 22 px outer window gap.
                x: 22
                height: parent.height
                spacing: 0

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    height: parent.height
                    width: workspaceContent.implicitWidth
                    color: theme.terminalGlass

                    Row {
                        id: workspaceContent
                        anchors.centerIn: parent
                        height: parent.height
                        spacing: 8

                        Text {
                            width: 16
                            height: parent.height
                            text: "󰣇"
                            color: theme.terminalPromptLight
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
                                    color: theme.terminalPromptLight
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.bold: modelData.focused
                                    font.pixelSize: 13
                                }

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    width: 10
                                    height: 2
                                    color: theme.primary
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
                            color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > 5
                                ? "#f5c542"
                                : theme.terminalPromptLight
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Powerline-style battery block, centered on the bar.
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                spacing: 0
                visible: UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    height: parent.height
                    width: batteryText.implicitWidth
                    color: theme.terminalGlass

                    Text {
                        id: batteryText
                        anchors.centerIn: parent
                        text: Math.round(UPower.displayDevice.percentage * 100)
                        color: UPower.displayDevice.percentage <= 0.20
                            ? "#BC4F4F"
                            : UPower.displayDevice.percentage <= 0.50
                                ? "#E9C46A"
                                : theme.terminalPromptLight
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Powerline-style clock block on the terminal background.
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                spacing: 0

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    height: parent.height
                    width: statusContent.implicitWidth
                    color: theme.terminalGlass

                    Row {
                        id: statusContent
                        anchors.centerIn: parent
                        spacing: 11

                        Text {
                            text: Qt.formatTime(clock.date, "HH:mm:ss")
                            color: theme.terminalPromptLight
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    height: parent.height
                    text: ""
                    color: theme.terminalGlass
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: parent.height
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Walt-inspired picker, built in Quickshell to match this desktop's colors.
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
                    color: theme.overlay

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.pickerOpen = false
                    }
                }

                Rectangle {
                    id: frame
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 130, 1640)
                    height: Math.min(parent.height - 130, 980)
                    radius: 0
                    color: "transparent"

                    Rectangle {
                        id: surface
                        anchors.fill: parent
                        anchors.margins: 0
                        radius: 0
                        color: theme.surface

                        // Prevent clicks in unused dialog space from closing the picker.
                        MouseArea { anchors.fill: parent }

                        Item {
                            id: content
                            anchors.fill: parent
                            anchors.margins: 30
                            z: 1
                            readonly property real leftWidth: Math.min(width * 0.34, 500)
                            readonly property real mainHeight: height - 76

                            Item {
                                id: libraryColumn
                                x: 0
                                y: 0
                                width: content.leftWidth
                                height: content.mainHeight

                                Rectangle {
                                    id: allBox
                                    width: parent.width
                                    height: parent.height * 0.61
                                    radius: 7
                                    color: "transparent"
                                    border.width: 2
                                    border.color: theme.primary

                                    Rectangle {
                                        x: 12
                                        y: -15
                                        width: allTitle.implicitWidth + 14
                                        height: 29
                                        color: surface.color
                                    }

                                    Text {
                                        id: allTitle
                                        x: 19
                                        y: -13
                                        text: "All [Name]"
                                        color: theme.primary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 15
                                    }

                                    ListView {
                                        id: wallpaperList
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        anchors.topMargin: 22
                                        clip: true
                                        spacing: 1
                                        model: root.wallpapers
                                        currentIndex: root.selectedIndex

                                        delegate: Item {
                                            required property var modelData
                                            required property int index
                                            width: wallpaperList.width
                                            height: 28

                                            Rectangle {
                                                anchors.fill: parent
                                                color: index === root.selectedIndex ? theme.surfaceHigh : "transparent"
                                                radius: 3
                                            }

                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 9
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: (index === root.selectedIndex ? "›  " : "   ") + modelData.name
                                                color: index === root.selectedIndex ? theme.primary : theme.foreground
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.bold: index === root.selectedIndex
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                                width: parent.width - 20
                                            }

                                            Rectangle {
                                                visible: modelData.path === root.currentWallpaperPath
                                                anchors.right: parent.right
                                                anchors.rightMargin: 9
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 10
                                                height: 10
                                                radius: 5
                                                color: theme.primary
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.selectedIndex = index
                                                onDoubleClicked: root.applyWallpaper(modelData.path)
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: folderBox
                                    anchors.top: allBox.bottom
                                    anchors.topMargin: 32
                                    width: parent.width
                                    height: parent.height - allBox.height - 32
                                    radius: 7
                                    color: "transparent"
                                    border.width: 2
                                    border.color: theme.outlineVariant

                                    Rectangle {
                                        x: 12
                                        y: -15
                                        width: folderTitle.implicitWidth + 14
                                        height: 29
                                        color: surface.color
                                    }

                                    Text {
                                        id: folderTitle
                                        x: 19
                                        y: -13
                                        text: "Folder [" + root.wallpapers.length + " walls]"
                                        color: theme.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 15
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 24
                                        anchors.topMargin: 28
                                        text: "›  " + (root.selectedWallpaper() ? root.selectedWallpaper().name : "No wallpapers")
                                            + "\n\n   " + root.wallpaperDirectory
                                            + "\n\n   Double-click or press Enter to apply."
                                        color: theme.foreground
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }

                            Item {
                                id: detailsColumn
                                x: content.leftWidth + 34
                                y: 0
                                width: content.width - x
                                height: content.mainHeight

                                Rectangle {
                                    id: previewBox
                                    width: parent.width
                                    height: parent.height * 0.62
                                    radius: 7
                                    color: "transparent"
                                    border.width: 2
                                    border.color: theme.outlineVariant

                                    Rectangle {
                                        x: 12
                                        y: -15
                                        width: previewTitle.implicitWidth + 14
                                        height: 29
                                        color: surface.color
                                    }

                                    Text {
                                        id: previewTitle
                                        x: 19
                                        y: -13
                                        text: "Preview"
                                        color: theme.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 15
                                    }

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        source: root.selectedWallpaper() ? "file://" + root.selectedWallpaper().path : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }

                                    Rectangle {
                                        visible: root.selectedWallpaper() && root.selectedWallpaper().path === root.currentWallpaperPath
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: 16
                                        anchors.rightMargin: 16
                                        width: 80
                                        height: 32
                                        radius: 16
                                        color: theme.primaryContainer

                                        Text {
                                            anchors.centerIn: parent
                                            text: "ACTIVE"
                                            color: theme.primaryContainerText
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.bold: true
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                Rectangle {
                                    id: metadataBox
                                    anchors.top: previewBox.bottom
                                    anchors.topMargin: 32
                                    width: parent.width
                                    height: parent.height - previewBox.height - 32
                                    radius: 7
                                    color: "transparent"
                                    border.width: 2
                                    border.color: theme.outlineVariant

                                    Rectangle {
                                        x: 12
                                        y: -15
                                        width: metadataTitle.implicitWidth + 14
                                        height: 29
                                        color: surface.color
                                    }

                                    Text {
                                        id: metadataTitle
                                        x: 19
                                        y: -13
                                        text: "Metadata"
                                        color: theme.secondary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 15
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 22
                                        anchors.topMargin: 27
                                        textFormat: Text.RichText
                                        text: "<b><font color='" + theme.tertiary + "'>File:</font></b> "
                                            + (root.selectedWallpaper() ? root.selectedWallpaper().name : "—")
                                            + "<br><b><font color='" + theme.tertiary + "'>Dir:</font></b> " + root.wallpaperDirectory
                                            + "<br><b><font color='" + theme.tertiary + "'>Resolution:</font></b> " + root.metaResolution
                                            + "&nbsp;&nbsp; <b><font color='" + theme.tertiary + "'>Size:</font></b> " + root.metaSize
                                            + "<br><b><font color='" + theme.tertiary + "'>Modified:</font></b> " + root.metaModified
                                            + "<br><b><font color='" + theme.tertiary + "'>Format:</font></b> " + root.metaFormat
                                        color: theme.foreground
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }

                            Rectangle {
                                id: helpBox
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 52
                                radius: 7
                                color: "transparent"
                                border.width: 2
                                border.color: theme.outlineVariant

                                Rectangle {
                                    x: 12
                                    y: -15
                                    width: helpTitle.implicitWidth + 14
                                    height: 29
                                    color: surface.color
                                }

                                Text {
                                    id: helpTitle
                                    x: 19
                                    y: -13
                                    text: "Help"
                                    color: theme.secondary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.bold: true
                                    font.pixelSize: 15
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "↑/↓ or j/k  move   |   Enter  apply   |   r  random   |   Esc  close"
                                    color: theme.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                        root.pickerOpen = false
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1)
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                        root.selectedIndex = Math.min(root.wallpapers.length - 1, root.selectedIndex + 1)
                    } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && root.selectedWallpaper()) {
                        root.applyWallpaper(root.selectedWallpaper().path)
                    } else if (event.key === Qt.Key_R && root.wallpapers.length > 0) {
                        root.selectedIndex = Math.floor(Math.random() * root.wallpapers.length)
                        root.applyWallpaper(root.selectedWallpaper().path)
                    } else {
                        return
                    }
                    event.accepted = true
                }
            }
        }
    }
}
