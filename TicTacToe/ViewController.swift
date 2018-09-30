//
//  ViewController.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gameLabel: UILabel!
    let game = Game()
    @IBOutlet weak var gameView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        gameLabel.text = nil
        game.delegate = self
        gameView.state = game.gameState
        gameView.positionTouchedAction = positionTouched(_:)
    }

    func positionTouched(_ position: Game.CellPosition)  {
        game.makeMove(at: position)
    }

    // MARK: - User Interaction
    @IBAction func reset(_ sender: UIButton) {
        gameLabel.text = nil
        gameView.winningPositions = nil
        game.reset()
    }
}

extension ViewController: GameDelegate {

    func gameFinished(result: Game.Player?, positions: [Game.CellPosition]?) {
        switch result {
        case .none: gameLabel.text = "Draw"
        case .some(let player): gameLabel.text = "\(player) won"
        }
        gameView.winningPositions = positions
    }

    func stateChanged(game: Game) {
        gameView.state = game.gameState
    }
}

