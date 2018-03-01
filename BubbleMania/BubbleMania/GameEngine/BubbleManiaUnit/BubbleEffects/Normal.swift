//
//  Normal.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// this class exists for completeness
class Normal: BubbleEffectStrategy {
    
    
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        // normal bubbles has no effect when exploding
        print("\(itself.row):\(itself.col) exploded normally")
        
        return []
    }
    
    func explodeAnimation(_ itself: GameBubble) {
        let burstingBubble = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "bubble-burst"), rowCount: 1, colCount: 4, idleSpriteIndex: IndexPath(item: 3, section: 0), animationDuration: 0.25)
        burstingBubble.center = itself.sprite.center
        
        itself.sprite.superview?.addSubview(burstingBubble)
        
        let bubbleCell = itself.sprite as! BubbleCell
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        bubbleCell.alpha = 0
                        bubbleCell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        burstingBubble.startAnimating()
                        burstingBubble.alpha = 0
                        },
                       completion: { isFinished in
                        guard isFinished else {
                            return
                        }
                        bubbleCell.bubbleType = .none
                        bubbleCell.alpha = 1
                        bubbleCell.transform = CGAffineTransform.identity
                        burstingBubble.removeFromSuperview()
                        })
    }
}
