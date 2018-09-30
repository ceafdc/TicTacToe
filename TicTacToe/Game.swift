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

        positions.append((0..<3).map {CellPosition(row: $0, column: 0)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 1)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 2)})

        positions.append((0..<3).map {CellPosition(row: 0, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 1, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 2, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: (2 - $0))})

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

    func serialized() -> String {
        var retVal: [String] = []
        for position in Game.CellPosition.allPositions {
            switch self[position] {
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
