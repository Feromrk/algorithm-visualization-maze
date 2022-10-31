import QtQuick 2.15
import QtQml.Models 2.15
import QtQml 2.15

Item {
    id: root

    property alias model: model
    property int rows: 10
    property int columns: 10

    // Execution speed of the mace generation in percent.
    property int generationSpeedPercent: 100

    function generate(algorithm) {
        if(algorithm === "DFS") {
            dfs.start()
        }
    }

    function reset() {
        model.init()
    }

    signal doneGenerating()

    ListModel {
        id: model

        // TODO: Initializing the model this way is not performant at all.
        function init() {
            clear()
            for(let i=0; i < root.columns; ++i) {
                for(let j=0; j < root.rows; ++j) {
                    model.append({
                        "columnIdx": i,
                        "rowIdx": j,
                        "visited": false,
                        "leftWall": true,
                        "rightWall": true,
                        "topWall": true,
                        "bottomWall": true,
                        "highlight":false
                    })
                }
            }
        }

        Component.onCompleted: {
            init()
        }
    }

    Item {
        id: internal

        // For accessing 1d array similar to 2d array.
        function index(columnIdx, rowIdx) {
            if(columnIdx < 0 || columnIdx > root.columns-1 || rowIdx < 0 || rowIdx > root.rows-1) {
                return -1
            }
            return rowIdx + columnIdx * root.columns
        }

        Item {
            id: dfs

            property var currentCell
            property var stack: []

            function start() {
                currentCell = model.get(0)
                dfs.currentCell.visited = true
                dfs.currentCell.highlight = true
                dfsTimer.start()
            }

            function getRandomNextUnvisitedNeighbor(cell) {
                let neighbors = []

                let left = model.get(internal.index(cell.columnIdx, cell.rowIdx-1))
                let right = model.get(internal.index(cell.columnIdx, cell.rowIdx+1))
                let top = model.get(internal.index(cell.columnIdx-1, cell.rowIdx))
                let bottom = model.get(internal.index(cell.columnIdx+1, cell.rowIdx))

                if(left && !left.visited) {
                    neighbors.push(left)
                }
                if(right && !right.visited) {
                    neighbors.push(right)
                }
                if(top && !top.visited) {
                    neighbors.push(top)
                }
                if(bottom && !bottom.visited) {
                    neighbors.push(bottom)
                }

                if(neighbors.length > 0) {
                    let r = Math.floor(Math.random()*neighbors.length)
                    return neighbors[r]
                }

                return undefined
            }

            function removeWalls(cellA, cellB) {
                let deltaRowIdx = cellA.rowIdx - cellB.rowIdx
                if(deltaRowIdx === 1) {
                    // B <- A; B is left neighbor of A
                    cellA.leftWall = false
                    cellB.rightWall = false
                } else if(deltaRowIdx === -1) {
                    // A -> B; B is right neighbor of A
                    cellA.rightWall = false
                    cellB.leftWall = false
                }

                let deltaColumnIdx = cellA.columnIdx - cellB.columnIdx
                if(deltaColumnIdx === 1) {
                    // B
                    // |
                    // A
                    // B is top neighbor of A
                    cellA.topWall = false
                    cellB.bottomWall = false
                } else if(deltaColumnIdx === -1) {
                    // A
                    // |
                    // B
                    // B is bottom neighbor of A
                    cellA.bottomWall = false
                    cellB.topWall = false
                }
            }

            function step() {
                let next = getRandomNextUnvisitedNeighbor(dfs.currentCell)
                if(next) {
                    dfs.currentCell.highlight = true
                    stack.push(dfs.currentCell)
                    removeWalls(dfs.currentCell, next)
                    next.visited = true
                    next.highlight = true
                    dfs.currentCell = next
                } else if(stack.length > 0) {
                    dfs.currentCell.highlight = false
                    dfs.currentCell = stack.pop()
                    dfs.currentCell.highlight = false
                } else {
                    dfsTimer.stop()
                    root.doneGenerating()
                }
            }

            Timer {
                id: dfsTimer
                interval: {
                    if(root.generationSpeedPercent >= 100) {
                        return 1
                    } else if(root.generationSpeedPercent <= 1) {
                        return 1000
                    }
                    return (100-root.generationSpeedPercent) * 10
                }
                repeat: true
                running: false
                onTriggered: {
                    dfs.step()
                }
            }
        }
    }
}
