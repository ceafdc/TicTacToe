//
//  Game.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

protocol GameDelegate {
    func stateChanged(game: Game)
    func gameFinished(result: Game.Player?, positions: [Game.CellPosition]?)
}

class Game {
    enum Player: String {
        case cross
        case nought

        static let allPlayers: [Player] = [.cross, .nought]

        var other: Player {
            switch self {
            case .cross: return .nought
            case .nought: return .cross
            }
        }
    }

    struct CellPosition: Hashable {
        let row: Int
        let column: Int

        static var allPositions: [CellPosition] {
            return (0..<9).map {CellPosition(row: $0/3, column: $0%3)}
        }
    }

    typealias GameState = [CellPosition: Player]


    var aiEnabled = false
    var canPlay = true
    var gameState: GameState {
        didSet {
            delegate?.stateChanged(game: self)
        }
    }
    var currentPlayer: Player
    var delegate: GameDelegate?

    static var winingPositions: [[CellPosition]] = {
        var positions: [[CellPosition]] = []

        let range = 0..<3

        positions.append(range.map {CellPosition(row: $0, column: 0)})
        positions.append(range.map {CellPosition(row: $0, column: 1)})
        positions.append(range.map {CellPosition(row: $0, column: 2)})

        positions.append(range.map {CellPosition(row: 0, column: $0)})
        positions.append(range.map {CellPosition(row: 1, column: $0)})
        positions.append(range.map {CellPosition(row: 2, column: $0)})

        positions.append(range.map {CellPosition(row: $0, column: $0)})

        positions.append(range.map {CellPosition(row: $0, column: (2 - $0))})

        return positions
    }()

    init() {
        gameState = [:]
        currentPlayer = .cross
        self.reset()
    }

    func reset() {
        for (position, _) in gameState {
            gameState[position] = nil
        }

        currentPlayer = .cross
        canPlay = true
    }

    func makeAIMove() {
        guard canPlay, gameState.countFreeSpaces > 0 else {return}
        self.makeMove(at: GameAI.shared.solveGame(state: gameState, for: currentPlayer))
    }

    func makeMove(at position: CellPosition) {
        guard canPlay, gameState[position] == nil else {return}

        gameState[position] = currentPlayer
        currentPlayer = currentPlayer.other
        checkGameFinished()
        if currentPlayer == .nought && aiEnabled {
            makeAIMove()
        }
    }

    func checkGameFinished() {
        let (finished, player, positions) = Game.checkGameFinished(gameState: gameState)
        if finished {
            delegate?.gameFinished(result: player, positions: positions)
            canPlay = false
        }
    }

    static func checkGameFinished(gameState: GameState) -> (Bool, Player?, [CellPosition]?){
        for positions in winingPositions {
            let states = positions.map {gameState[$0]}
            for player in Player.allPlayers {
                if states.count(state: player) == 3 {
                    return (true, player, positions)
                }
            }
        }

        if gameState.countFreeSpaces == 0 {
            return (true, nil, nil)
        }

        return (false, nil, nil)
    }
}

extension Dictionary where Key == Game.CellPosition, Value == Game.Player {
    var countFreeSpaces: Int {
        return 9 - count
    }

    var freeSpaces: [Game.CellPosition] {
        return Game.CellPosition.allPositions.filter {self[$0] == nil}
    }

    var centerOfMass: (Double, Double) {
        var centerOfMass: (Double, Double) = (0, 0)
        var total = 0
        for position in Game.CellPosition.allPositions {
            if let player = self[position] {
                let mass: Double
                switch player {
                case .cross: mass = 3
                case .nought: mass = 2
                }
                centerOfMass.0 += mass * (Double(position.column) - 1)
                centerOfMass.1 += mass * (Double(position.row) - 1)
                total += 1
            }
        }
        centerOfMass.0 /= Double(Swift.max(1, total))
        centerOfMass.1 /= Double(Swift.max(1, total))

        return centerOfMass
    }

    func rotated() -> [Game.CellPosition: Game.Player] {
        var cm = centerOfMass
        if abs(cm.0) < Double.ulpOfOne && abs(cm.1) < Double.ulpOfOne { // do nothing
            return self
        }
        var copy = self
        if cm.0 < 0 {  // flip X
            for position in Game.CellPosition.allPositions {
                let newPosition = Game.CellPosition(row: position.row, column: 2 - position.column)
                copy[newPosition] = self[position]
            }
            cm.0 *= -1
        }

        if cm.1 < 0 { // flip Y
            for position in Game.CellPosition.allPositions {
                let newPosition = Game.CellPosition(row: 2 - position.row, column: position.column)
                copy[newPosition] = self[position]
            }
            cm.1 *= -1
        }

        if cm.0 > cm.1 {
            for position in Game.CellPosition.allPositions {
                let newPosition = Game.CellPosition(row: position.column, column: position.row)
                copy[newPosition] = self[position]
            }
            cm = (cm.1, cm.0)
        }

        return copy
    }

    func serialized() -> String {
        var copy = self

        copy = copy.rotated()

        var retVal: [String] = []
        for position in Game.CellPosition.allPositions {
            switch copy[position] {
            case .none: retVal.append(" ")
            case .some(let player):
                switch player {
                case .cross: retVal.append("X")
                case .nought: retVal.append("O")
                }
            }
        }

        return retVal.joined()
    }
}

extension Array where Iterator.Element == Game.Player? {
    func count(state: Game.Player) -> Int {
        return reduce(0) {$0 + ($1 == state ? 1 : 0)}
    }
}
