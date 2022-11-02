import QtQuick 2.15
import QtQuick.Controls 2.15
import "./views"
import "components"

ApplicationWindow {
    width: 1000
    height: 1000
    visible: true
    title: "Maze"
    modality: Qt.ApplicationModal

    Maze {
        anchors.fill: parent
    }
}
