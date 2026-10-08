import QtQuick
import Quickshell

PanelWindow {
    property var targetScreen
    property var shellRoot
    property var themePalette

    screen: targetScreen
    visible: shellRoot && shellRoot.notificationPopupVisible && shellRoot.notificationPopup
    implicitWidth: 300
    implicitHeight: toast.implicitHeight
    color: "transparent"
    focusable: false
    exclusiveZone: 0

    anchors {
        top: true
        right: true
    }

    margins {
        top: 42
        right: 55
    }

    Rectangle {
        id: toast
        readonly property var notification: shellRoot ? shellRoot.notificationPopup : null
        width: parent.width
        implicitHeight: Math.max(84, bodyLabel.visible ? bodyLabel.implicitHeight + 58 : 82)
        radius: 2
        color: "#06191d"
        border.width: 1
        border.color: "#585858"

        Rectangle {
            id: iconDisc
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.top: parent.top
            anchors.topMargin: 16
            width: 40
            height: 40
            radius: 20
            color: "#153940"
            border.width: 0

            Text {
                anchors.centerIn: parent
                text: toast.notification && toast.notification.urgency > 1 ? "󰀦" : "󰂚"
                color: toast.notification && toast.notification.urgency > 1 ? "#BC4F4F" : themePalette.terminalPromptLight
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 19
            }
        }

        Rectangle {
            anchors.left: iconDisc.right
            anchors.leftMargin: 13
            anchors.top: parent.top
            anchors.topMargin: 20
            width: 5
            height: 5
            radius: 3
            color: toast.notification && toast.notification.urgency > 1 ? "#BC4F4F" : "#b798e8"
        }

        Text {
            id: titleLabel
            anchors.left: iconDisc.right
            anchors.leftMargin: 24
            anchors.right: closeButton.left
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 14
            text: toast.notification && toast.notification.summary.length > 0
                ? toast.notification.summary
                : toast.notification ? toast.notification.appName : ""
            color: themePalette.terminalPromptLight
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        Text {
            id: bodyLabel
            anchors.left: iconDisc.right
            anchors.leftMargin: 13
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: titleLabel.bottom
            anchors.topMargin: 6
            visible: toast.notification && toast.notification.body.length > 0
            text: toast.notification ? toast.notification.body : ""
            textFormat: Text.PlainText
            color: themePalette.terminalPromptLight
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Rectangle {
            id: closeButton
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 10
            width: 22
            height: 22
            radius: 11
            color: closeMouse.containsMouse ? "#294850" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                color: themePalette.terminalPromptLight
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: shellRoot.hideNotificationPopup()
            }
        }

        MouseArea {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: closeButton.left
            anchors.rightMargin: 5
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                shellRoot.notificationCenterOpen = true
                shellRoot.notificationPopupVisible = false
            }
        }
    }
}
