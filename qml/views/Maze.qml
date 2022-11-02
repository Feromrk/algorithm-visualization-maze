import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import "../components"

Item {
    id: root

    Options {
        id: generationAndSolvingOptions
        visible: false
        anchors.fill: parent
        onStartClicked: {
            if(root.state === "generationOptions") {
                Cells.generate(generationAndSolvingOptions.algorithm)
            } else if(root.state === "solvingOptions") {
                Cells.solve(generationAndSolvingOptions.algorithm)
            }

            root.state = "running"
        }
    }

    GridLayout {
        id: maze
        anchors {
            top: parent.top
            topMargin: 50
            horizontalCenter: parent.horizontalCenter
        }
        height: Math.min(parent.height, parent.width) - anchors.topMargin
        width: height
        visible: false
        columns: Cells.columns
        rows: Cells.rows
        rowSpacing: 0
        columnSpacing: 0

        Repeater {
            model: Cells.model

            delegate: Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: visited ? "gray" : "transparent"

                Rectangle {
                    id: highlight
                    anchors.fill: parent
                    color: "steelblue"
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
        id: generationAndSolvingSettings
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
            id: algorithmSpeedPercentSlider
            from: 60
            to: 100
            value: 100
            Component.onCompleted: {
                Cells.algorithmSpeedPercent = Qt.binding(()=>value);
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 15
        Button {
            id: restartGenerationButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: "Restart generation"
            padding: 30
            onClicked: {
                root.state = "generationOptions"
            }
        }
        Button {
            id: solveButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: "Solve"
            padding: 30
            onClicked: {
                root.state = "solvingOptions"
            }
        }
        Button {
            id: restartSolvingButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: "Restart solving"
            padding: 30
            onClicked: {
                root.state = "solvingOptions"
            }
        }
        Button {
            id: restartFromBeginningButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: "Restart from beginning"
            padding: 30
            onClicked: {
                root.state = "generationOptions"
            }
        }
    }

    Connections {
        target: Cells
        function onDoneGenerating() {
            root.state = "doneGenerating"
        }
        function onDoneSolving() {
            root.state = "doneSolving"
        }
    }

    state: "generationOptions"
    states: [
        State {
            name: "generationOptions"
            PropertyChanges {
                target: generationAndSolvingOptions
                visible: true
                headline: "Algorithm visualization: maze generation"
            }
            StateChangeScript {
                script: {
                    Cells.reset()
                }
            }
        },
        State {
            name: "solvingOptions"
            PropertyChanges {
                target: generationAndSolvingOptions
                visible: true
                headline: "Algorithm visualization: maze solving"
            }
        },
        State {
            name: "running"
            PropertyChanges {
                target: maze
                visible: true
            }
            PropertyChanges {
                target: generationAndSolvingSettings
                visible: true
            }
        },
        State {
            name: "doneGenerating"
            PropertyChanges {
                target: maze
                visible: true
            }
            PropertyChanges {
                target: restartGenerationButton
                visible: true
            }
            PropertyChanges {
                target: solveButton
                visible: true
            }
        },
        State {
            name: "doneSolving"
            PropertyChanges {
                target: maze
                visible: true
            }
            PropertyChanges {
                target: restartSolvingButton
                visible: true
            }
            PropertyChanges {
                target: restartFromBeginningButton
                visible: true
            }
        }
    ]
}
