pragma Singleton
import QtQuick 2.15
import QtQml.Models 2.15
import QtQml 2.15

Item {
    id: root

    property alias model: model
    property int rows: 25
    property int columns: 25

    // Execution speed of the mace generation in percent.
    property int algorithmSpeedPercent: 100

    function generate(algorithm) {
        if(algorithm === "DFS") {
            generateDFS.start()
        }
    }

    function solve(algorithm){
        if(algorithm === "DFS") {
            solveDFS.start()
        }
    }

    function reset() {
        model.init()
    }

    signal doneGenerating()
    signal doneSolving()

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
            model.get(0).leftWall = false
            model.get(root.columns*root.rows-1).rightWall = false
        }

        function unvisitAll() {
            for(let i=0; i < model.count; ++i) {
                let cell = model.get(i)
                cell.visited = false
                cell.highlight = false
            }
        }
    }

    Item {
        id: internal

        // For accessing 1d arrays similar to 2d arrays.
        function index(columnIdx, rowIdx) {
            if(columnIdx < 0 || columnIdx > root.columns-1 || rowIdx < 0 || rowIdx > root.rows-1) {
                return -1
            }
            return rowIdx + columnIdx * root.columns
        }

        Timer {
            id: timeout
            property var callback

            interval: {
                if(root.algorithmSpeedPercent >= 100) {
                    return 1
                } else if(root.algorithmSpeedPercent <= 1) {
                    return 1000
                }
                return (100-root.algorithmSpeedPercent) * 10
            }
            repeat: true
            running: false
            onTriggered: {
                callback()
            }
        }

        Item {
            id: generateDFS

            property var currentCell
            property var stack: []

            function start() {
                generateDFS.currentCell = model.get(0)
                generateDFS.currentCell.visited = true
                generateDFS.currentCell.highlight = true
                timeout.callback = generateDFS.step
                timeout.start()
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
                let next = getRandomNextUnvisitedNeighbor(generateDFS.currentCell)
                if(next) {
                    generateDFS.currentCell.highlight = true
                    stack.push(generateDFS.currentCell)
                    removeWalls(generateDFS.currentCell, next)
                    next.visited = true
                    next.highlight = true
                    generateDFS.currentCell = next
                } else if(stack.length > 0) {
                    generateDFS.currentCell.highlight = false
                    generateDFS.currentCell = stack.pop()
                    generateDFS.currentCell.highlight = false
                } else {
                    timeout.stop()
                    root.doneGenerating()
                }
            }
        }

        Item {
            id: solveDFS

            property var currentCell
            property var stack: []

            function start() {
                model.unvisitAll()
                currentCell = model.get(0)
                solveDFS.currentCell.visited = true
                solveDFS.currentCell.highlight = true
                timeout.callback = solveDFS.step
                timeout.start()
            }

            function end() {
                timeout.stop()
                root.doneSolving()
            }

            function getRandomNextAccessibleNeighbor(cell) {
                let neighbors = []

                let left = cell.leftWall ? undefined : model.get(internal.index(cell.columnIdx, cell.rowIdx-1))
                let right = cell.rightWall ? undefined : model.get(internal.index(cell.columnIdx, cell.rowIdx+1))
                let top = cell.topWall ? undefined : model.get(internal.index(cell.columnIdx-1, cell.rowIdx))
                let bottom = cell.bottomWall ? undefined : model.get(internal.index(cell.columnIdx+1, cell.rowIdx))

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

            function step() {
                if(solveDFS.currentCell.columnIdx === root.columns-1 && solveDFS.currentCell.rowIdx === root.rows-1) {
                    solveDFS.end()
                    return
                }
                solveDFS.currentCell.highlight = false
                let next = getRandomNextAccessibleNeighbor(solveDFS.currentCell)
                if(next) {
                    stack.push(solveDFS.currentCell)
                    next.visited = true
                    solveDFS.currentCell = next
                } else if(stack.length > 0) {
                    solveDFS.currentCell = stack.pop()
                } else {
                    console.error("visited all cells, but exit not found")
                    solveDFS.end()
                }
                solveDFS.currentCell.highlight = true
            }
        }
    }
}
