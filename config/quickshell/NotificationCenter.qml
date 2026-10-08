import QtQuick
import Quickshell

PanelWindow {
    property var targetScreen
    property var shellRoot
    property var themePalette

    screen: targetScreen
    visible: shellRoot && shellRoot.notificationCenterOpen
    color: "transparent"
    focusable: true
    exclusiveZone: 0

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.notificationCenterOpen = false
        }

        FocusScope {
            anchors.fill: parent
            focus: true
            z: 1

            Rectangle {
                id: notificationPanel
                anchors.centerIn: parent
                width: Math.min(520, parent.width - 48)
                height: Math.min(420, parent.height - 72)
                radius: 2
                color: "#06191d"
                border.width: 1
                border.color: "#585858"

                MouseArea {
                    anchors.fill: parent
                }

                Item {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 22

                    Item {
                        id: header
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 38

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Notification Center"
                            color: themePalette.terminalPromptLight
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                            font.pixelSize: 18
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: clearLabel.implicitWidth + 24
                            height: 30
                            radius: 9
                            color: themePalette.terminalGlass
                            border.width: 0

                            Text {
                                id: clearLabel
                                anchors.centerIn: parent
                                text: "Clear all"
                                color: themePalette.terminalPromptLight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: shellRoot.notificationHistory.count > 0
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: shellRoot.clearNotifications()
                            }
                        }
                    }

                    Rectangle {
                        id: tabs
                        anchors.top: header.bottom
                        anchors.topMargin: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 38
                        radius: 11
                        color: themePalette.terminalGlass

                        Repeater {
                            model: ["Today", "This Week", "Earlier"]

                            delegate: Rectangle {
                                required property int index
                                required property string modelData

                                x: index * parent.width / 3
                                width: parent.width / 3
                                height: parent.height
                                radius: 9
                                color: shellRoot.notificationTab === index ? "#1d3035" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: themePalette.terminalPromptLight
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: shellRoot.notificationTab = index
                                }
                            }
                        }
                    }

                    Flickable {
                        id: notificationList
                        anchors.top: tabs.bottom
                        anchors.topMargin: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        contentWidth: width
                        contentHeight: notificationColumn.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: notificationColumn
                            width: notificationList.width
                            spacing: 9

                            Repeater {
                                model: shellRoot.notificationHistory

                                delegate: Item {
                                    required property int index
                                    required property var notification
                                    required property double receivedAt

                                    readonly property bool inSelectedGroup: shellRoot.notificationMatchesTab(receivedAt)
                                    readonly property string summaryText: notification.summary.length > 0
                                        ? notification.summary : notification.appName
                                    readonly property string bodyText: notification.body
                                    visible: inSelectedGroup
                                    width: notificationColumn.width
                                    height: inSelectedGroup ? Math.max(76, bodyLabel.visible ? bodyLabel.implicitHeight + 54 : 68) : 0

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 15
                                        color: themePalette.terminalGlass
                                        border.width: 0
                                    }

                                    Rectangle {
                                        id: iconDisc
                                        anchors.left: parent.left
                                        anchors.leftMargin: 13
                                        anchors.top: parent.top
                                        anchors.topMargin: 13
                                        width: 36
                                        height: 36
                                        radius: 18
                                        color: "#153940"
                                        border.width: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: notification.urgency > 1 ? "󰀦" : "󰂚"
                                            color: notification.urgency > 1 ? "#BC4F4F" : themePalette.terminalPromptLight
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 17
                                        }
                                    }

                                    Rectangle {
                                        anchors.left: iconDisc.right
                                        anchors.leftMargin: 12
                                        anchors.top: parent.top
                                        anchors.topMargin: 18
                                        width: 5
                                        height: 5
                                        radius: 3
                                        color: notification.urgency > 1 ? "#BC4F4F" : "#b798e8"
                                    }

                                    Text {
                                        id: summaryLabel
                                        anchors.left: iconDisc.right
                                        anchors.leftMargin: 23
                                        anchors.right: timeLabel.left
                                        anchors.rightMargin: 9
                                        anchors.top: parent.top
                                        anchors.topMargin: 12
                                        text: summaryText
                                        color: themePalette.terminalPromptLight
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: true
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: timeLabel
                                        anchors.right: parent.right
                                        anchors.rightMargin: 15
                                        anchors.top: parent.top
                                        anchors.topMargin: 13
                                        text: shellRoot.relativeNotificationTime(receivedAt)
                                        color: themePalette.terminalPromptLight
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        id: bodyLabel
                                        anchors.left: iconDisc.right
                                        anchors.leftMargin: 12
                                        anchors.right: parent.right
                                        anchors.rightMargin: 16
                                        anchors.top: summaryLabel.bottom
                                        anchors.topMargin: 5
                                        visible: bodyText.length > 0
                                        text: bodyText
                                        textFormat: Text.PlainText
                                        color: themePalette.terminalPromptLight
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            shellRoot.removeNotification(index)
                                        }
                                    }
                                }
                            }

                            Item {
                                width: notificationColumn.width
                                height: 150
                                visible: shellRoot.notificationHistory.count === 0

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 37
                                    text: "󰂚"
                                    color: themePalette.terminalPromptLight
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 38
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 89
                                    text: "Nothing new"
                                    color: themePalette.terminalPromptLight
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    shellRoot.notificationCenterOpen = false
                    event.accepted = true
                }
            }
        }
    }
}
