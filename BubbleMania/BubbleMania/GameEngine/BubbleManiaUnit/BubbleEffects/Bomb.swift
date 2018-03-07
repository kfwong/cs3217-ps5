//
//  Bomb.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// Bomb bubbles destroy all bubbles adjacent to itself
class Bomb: BubbleEffectStrategy {

    private(set) var isDestructible: Bool = true

    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        //print("\(itself.row):\(itself.col) exploded with bomb effect")

        // gamebubble can calculate the neighbour index in a hexagon grid
        let affectedIndexes = itself.neighbourIndexes()

        // filter active bubbles to leave only those adjacent to this gamebubble
        return activeBubbles.filter { affectedIndexes.contains(IndexPath(item: $0.col, section: $0.row)) }

    }

    // bomb animation will expand itself and fade out
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble]) {
        guard let bubbleCell = itself.sprite as? BubbleCell else {
            return
        }

        var bombs: [UIAnimationView] = []

        var animateGameBubbles = affectedGameBubbles
        animateGameBubbles.append(itself)

        animateGameBubbles.forEach {
            let bomb = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "fire"), rowCount: 4, colCount: 5)
            bomb.center = $0.sprite.center
            $0.sprite.superview?.addSubview(bomb)
            bombs.append(bomb)
        }

        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        bubbleCell.alpha = 0
                        bubbleCell.transform = CGAffineTransform(scaleX: 2, y: 2)
                        bombs.forEach { $0.startAnimating() }
                        },
                       completion: { isFinished in
                        guard isFinished else {
                            return
                        }
                        bubbleCell.bubbleType = .none
                        bubbleCell.alpha = 1
                        bubbleCell.transform = CGAffineTransform.identity
                        bombs.forEach { $0.removeFromSuperview() }
                        })
    }
}
