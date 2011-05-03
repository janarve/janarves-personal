import QtQuick 1.0

Rectangle {
    id: container
    property string text
    property bool checked
    width: label.width > 40 ? label.width + 10: 50
    height: label.height + 20
    color: checked ? 'red' : '#ffc0c0'

    function toggle() {
        checked = !checked;
    }

    Text {
        id: label;
        text: container.text;
        y : 10
        x : 5
    }

    MouseArea {
        anchors.fill: parent;
        onClicked: {
            if (mouse.button == Qt.LeftButton)
                parent.toggle();
        }
    }
}
