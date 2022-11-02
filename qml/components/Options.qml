import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

ColumnLayout {
    id: root

    property alias headline: headline.text
    property string algorithm: "DFS"
    signal startClicked

    Text {
        id: headline
        font.pointSize: 25
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
    }
    Text {
        text: "Choose algorithm:"
        font.pointSize: 20
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
    }
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        RadioButton {
            id: dfsSelection
            checked: true
            text: "Randomized depth-first search (iterative)"
            onCheckedChanged: {
                if(checked) {
                    root.algorithm = "DFS"
                }
            }
        }
        RadioButton {
            enabled: false
            text: "More coming soon ..."
        }
    }
    Button {
        text: "Start"
        padding: 30
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
            root.startClicked()
        }
    }
}
