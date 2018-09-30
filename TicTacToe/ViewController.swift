//
//  ViewController.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let game = Game()
    @IBOutlet weak var gameView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        game.delegate = self
        gameView.gameState = game.gameState
        gameView.positionTouchedAction = positionTouched(_:)
    }

    func positionTouched(_ position: Game.CellPosition)  {
        game.makeMove(at: position)
    }
}

extension ViewController: GameDelegate {
    func stateChanged(game: Game) {
        gameView.gameState = game.gameState
    }
}

