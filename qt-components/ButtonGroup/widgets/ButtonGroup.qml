import QtQuick 1.0

import "ButtonGroup.js" as Script

Item {
    id: container;
    property variant buttonList;
    property bool allowMultiSelection;  // not implemented, but should be if this is the
                                        // chosen approach
    property bool allowNoneSelected;

    onButtonListChanged: {
        Script.init();
        for (var i = 0; i < buttonList.length; ++i) {
            Script.addItem(buttonList[i]);
        }
    }
}
