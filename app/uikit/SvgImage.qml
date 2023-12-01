import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    property alias image: image
    property color foreground: "black"
    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight

    Image {
        id: image
        anchors.centerIn: parent
        visible: false
    }
    ColorOverlay {
        anchors.fill: image
        source: image
        color: parent.foreground
    }
}
