//
//  Lightning.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// Lightning bubbles destroy all bubbles of same row as it is
class Lightning: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        print("\(itself.row):\(itself.col) exploded with lightning effect")
        
        return activeBubbles.filter{ $0.row == itself.row } // get all bubbles same row as itself
        
    }
    
    func explodeAnimation(_ itself: GameBubble) {
        let bubbleCell = itself.sprite as! BubbleCell
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        bubbleCell.alpha = 0
                        },
                       completion: { isFinished in
                        guard isFinished else {
                            return
                        }
                        bubbleCell.bubbleType = .none
                        bubbleCell.alpha = 1
                        })
    }
}

