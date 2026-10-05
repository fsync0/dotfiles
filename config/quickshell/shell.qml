//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            implicitHeight: 31
            color: "transparent"
            focusable: false
            // Adds a small clearance between the underline and tiled windows.
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
                        // Keep the compact five-workspace menu from the reference.
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
}
