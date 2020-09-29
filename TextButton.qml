import QtQuick 2.0

Item {
    id: button

    property alias text: innerText.text;

    width : innerText.paintedWidth + 20
    height: 30

    property color color        : "lightgray"
    property color colorHover   : "#aaaaaa"
    property color colorPressed : "slategray"
    property color colorDisabled: "red"

    property int fontSize    : 10
    property int borderWidth : 1
    property int borderRadius: 20

    signal clicked

    onEnabledChanged: {
        if (enabled)
            innerRect.color = button.color;
        else
            innerRect.color = colorDisabled;
    }

    opacity: enabled ? 1 : 0.2

    //Rectangle to draw the button
    Rectangle {
        id: innerRect
        anchors.fill: parent

        radius: borderRadius
        color : button.enabled ? button.color : button.colorDisabled

        border.width: borderWidth
        border.color: "black"

        Text {
            id: innerText
            font.pointSize  : fontSize
            anchors.centerIn: parent
        }
    }



    //Mouse area to react on click events
    MouseArea {
        hoverEnabled: true
        anchors.fill: button

        onEntered: {
            if (button.enabled)
                innerRect.color = colorHover;
        }
        onExited: {
            if (button.enabled)
                innerRect.color = button.color;
        }
        onClicked: { button.clicked();}
    }
}
