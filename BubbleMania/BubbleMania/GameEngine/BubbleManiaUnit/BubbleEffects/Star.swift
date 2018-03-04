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
    
    private(set) var isDestructible: Bool = true
    
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        //print("\(itself.row):\(itself.col) exploded with star effect")

        // filter the list of gamebubbles of same type as the projectile
        return activeBubbles.filter{ $0.bubbleType == projectile.bubbleType}
    }
    
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble]) {
    
        var bombs: [UIAnimationView] = []
        
        var animateGameBubbles = affectedGameBubbles
        animateGameBubbles.append(itself)
        
        animateGameBubbles.forEach{
            let bomb = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "star"), rowCount: 2, colCount: 5, animationDuration: 0.8)
            bomb.center = $0.sprite.center
            $0.sprite.superview?.addSubview(bomb)
            bombs.append(bomb)
        }
        
        let bubbleCell = itself.sprite as! BubbleCell
        
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        bubbleCell.alpha = 0
                        bombs.forEach{ $0.startAnimating() }
        },
                       completion: { isFinished in
                        guard isFinished else {
                            return
                        }
                        bubbleCell.bubbleType = .none
                        bubbleCell.alpha = 1
                        bombs.forEach{ $0.removeFromSuperview() }
        })
        
    }
}


