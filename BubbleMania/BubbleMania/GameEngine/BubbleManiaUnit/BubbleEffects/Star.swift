//
//  Star.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// Star bubbles destroy all bubbles of same type on the entire grid
class Star: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        print("\(itself.row):\(itself.col) exploded with star effect")

        // filter the list of gamebubbles of same type as the projectile
        return activeBubbles.filter{ $0.bubbleType == projectile.bubbleType}
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


