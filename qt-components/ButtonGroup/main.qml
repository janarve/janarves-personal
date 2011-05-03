import QtQuick 1.0

import "widgets"

Rectangle {
    width: 400
    height: 300
    id: buttonRow;

    ToggleButton {
        id: b1
        text: 'Thyme'
        anchors.top: buttonRow.top
        anchors.left: buttonRow.left
    }
    ToggleButton {
        id: b2
        text: 'Basil'
        checked: true
        anchors.top: b1.bottom
        anchors.left: buttonRow.left
    }

    ToggleButton {
        id: b3
        x: 0
        y: 80
        text: 'Rosemary'
        anchors.top: b2.bottom
        anchors.left: buttonRow.left
    }

    ToggleButton {
        id: b4
        x: 0
        y: 120
        text: 'Not part of button group'
        anchors.top: b3.bottom
        anchors.left: buttonRow.left
    }

    ButtonGroup {
        id: group
        buttonList: [b1, b2, b3]
    }

}
