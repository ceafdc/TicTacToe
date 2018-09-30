//
//  GameView.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class GameView: UIView {

    var gameState: Game.GameState? {
        didSet {
            setNeedsDisplay()
        }
    }

    var positionTouchedAction: ((Game.CellPosition)->Void)?

    private let padding: CGFloat = 0.05
    private var gridSize: CGFloat {
        return min(bounds.width, bounds.height)/3
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(sender:))))
    }

    fileprivate func drawVerticalLines() {
        UIColor.black.setStroke()
        for i in 1...2 {
            let line = UIBezierPath()
            let xOffset: CGFloat = CGFloat(i) * gridSize
            line.move(to: CGPoint(x: xOffset, y: bounds.height * (1 - padding)))
            line.addLine(to: CGPoint(x: xOffset, y: bounds.height * padding))
            line.lineWidth = 1
            line.stroke()
        }
    }

    fileprivate func drawHorizontalLines() {
        UIColor.black.setStroke()
        for i in 1...2 {
            let line = UIBezierPath()
            let yOffset: CGFloat = CGFloat(i) * gridSize
            line.move(to: CGPoint(x: bounds.width * (1 - padding), y: yOffset))
            line.addLine(to: CGPoint(x: bounds.width * padding, y: yOffset))
            line.lineWidth = 1
            line.stroke()
        }
    }

    fileprivate func drawCross() {
        let cross = UIBezierPath()
        cross.move(to: CGPoint(x: -gridSize/2, y: -gridSize/2))
        cross.addLine(to: CGPoint(x: gridSize/2, y: gridSize/2))

        cross.move(to: CGPoint(x: gridSize/2, y: -gridSize/2))
        cross.addLine(to: CGPoint(x: -gridSize/2, y: gridSize/2))

        cross.lineWidth = 3
        cross.stroke()
    }

    fileprivate func drawNought() {
        let circle = UIBezierPath(arcCenter: .zero,
                                  radius: gridSize/2,
                                  startAngle: 0,
                                  endAngle: 2 * .pi,
                                  clockwise: true)
        circle.lineWidth = 3
        circle.stroke()
    }

    fileprivate func draw(_ state: Game.CellState, at position: Game.CellPosition) {
        guard state != .free else {return}
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        ctx.translateBy(x: (CGFloat(position.column) + 0.5) * gridSize, y: (CGFloat(position.row) + 0.5) * gridSize)
        ctx.scaleBy(x: 0.8, y: 0.8)

        switch state {
        case .free: fatalError("Invalid State")
        case .cross: drawCross()
        case .nought: drawNought()
        }

        ctx.restoreGState()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let gameState = gameState else {return}

        drawVerticalLines()
        drawHorizontalLines()

        for (pos, state) in gameState {
            draw(state, at: pos)
        }
    }

    // MARK: - User Interaction

    @objc
    func tapped(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        var x = Int(floor(location.x / gridSize))
        var y = Int(floor(location.y / gridSize))

        x = min(max(0, x), 2)
        y = min(max(0, y), 2)

        positionTouchedAction?(Game.CellPosition(row: y, column: x))
    }
}
