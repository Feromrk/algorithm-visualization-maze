import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../components"

Item {
    id: root

    ColumnLayout {
        id: chooseAlgorithm
        anchors.fill: parent

        Text {
            text: "Algorithm visualization: maze generation"
            font.pointSize: 25
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: "Choose algorithm:"
            font.pointSize: 20
            Layout.alignment: Qt.AlignHCenter
        }
        Column {
            id: options
            property string algorithm: "DFS"
            Layout.alignment: Qt.AlignHCenter
            RadioButton {
                id: dfsSelection
                checked: true
                text: "Randomized depth-first search (iterative)"
                onCheckedChanged: {
                    if(checked) {
                        options.algorithm = "DFS"
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
                root.state = "generate"
                cells.generate(options.algorithm)
            }
        }
    }

    Cells {
        id: cells
        rows: maze.rows
        columns: maze.columns
        onDoneGenerating: root.state = "done"
        generationSpeedPercent: generationSpeedPercentSlider.value
    }
    GridLayout {
        id: maze
        anchors.fill: parent
        anchors.margins: 50
        visible: false
        columns: 25
        rows: columns
        rowSpacing: 0
        columnSpacing: 0

        Repeater {
            model: cells.model

            delegate: Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: visited ? "gray" : "transparent"

                Rectangle {
                    id: highlight
                    anchors.fill: parent
                    color: "green"
                    visible: model.highlight
                }

                readonly property int wallLineWidth: 1
                Rectangle {
                    id: leftWall
                    visible: model.leftWall
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: wallLineWidth
                    color: "black"
                }
                Rectangle {
                    id: rightWall
                    visible: model.rightWall
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: wallLineWidth
                    color: "black"
                }
                Rectangle {
                    id: topWall
                    visible: model.topWall
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: wallLineWidth
                    color: "black"
                }
                Rectangle {
                    id: bottomWall
                    visible: model.bottomWall
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: wallLineWidth
                    color: "black"
                }
            }
        }
    }

    RowLayout {
        id: settings
        visible: false
        spacing: 0
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        height: maze.anchors.topMargin
        Text {
            text: "Speed"
            font.pixelSize: 19
        }
        Slider {
            id: generationSpeedPercentSlider
            from: 60
            to: 100
            value: 100
        }
    }

    Button {
        id: restartButton
        anchors.centerIn: parent
        visible: false
        text: "Restart"
        padding: 30
        onClicked: {
            cells.reset()
            root.state = "select"
        }
    }

    states: [
        State {
            name: "select"
            PropertyChanges {
                target: chooseAlgorithm
                visible: true
            }
            PropertyChanges {
                target: maze
                visible: false
            }
            PropertyChanges {
                target: settings
                visible: false
            }
        },
        State {
            name: "generate"
            PropertyChanges {
                target: chooseAlgorithm
                visible: false
            }
            PropertyChanges {
                target: maze
                visible: true
            }
            PropertyChanges {
                target: settings
                visible: true
            }
        },
        State {
            name: "done"
            PropertyChanges {
                target: chooseAlgorithm
                visible: false
            }
            PropertyChanges {
                target: maze
                visible: true
            }
            PropertyChanges {
                target: restartButton
                visible: true
            }
            PropertyChanges {
                target: settings
                visible: false
            }
        }
    ]
}
