//
//  Normal.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class Normal: BubbleEffectStrategy {
    
    private(set) var isDestructible: Bool = true
    
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        // does not affect any other gamebubbles
        return []
    }
    
    // normal explode animation diminished and burst
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble]) {
        
        let burstingBubble = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "bubble-burst"), rowCount: 1, colCount: 4, idleSpriteIndex: IndexPath(item: 3, section: 0), animationDuration: 0.25)
        burstingBubble.center = itself.sprite.center
        itself.sprite.superview?.addSubview(burstingBubble)
        
        let pokeball = UIImageView(image: #imageLiteral(resourceName: "pokeball"))
        pokeball.alpha = 0
        pokeball.center = itself.sprite.center
        pokeball.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        itself.sprite.superview?.addSubview(pokeball)
        
        let bubbleCell = itself.sprite as! BubbleCell
        
        UIView.animateKeyframes(withDuration: 1.1, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                bubbleCell.bubbleImage.alpha = 0
                bubbleCell.bubbleImage.layer.borderWidth = 0
                bubbleCell.bubbleImage.layer.borderColor = UIColor.clear.cgColor
                bubbleCell.transform = CGAffineTransform(scaleX: 0, y: 0)
                bubbleCell.backgroundColor = UIColor.white
                
                burstingBubble.startAnimating()
                burstingBubble.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2, animations: {
                pokeball.alpha = 1
                pokeball.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.5, animations: {
                // delay
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.2, animations: {
                pokeball.alpha = 0
            })
            
        }, completion: { isFinished in
            guard isFinished else {
                return
            }
            bubbleCell.bubbleImage.transform = CGAffineTransform.identity
            bubbleCell.transform = CGAffineTransform.identity
            bubbleCell.bubbleType = .none
            
            burstingBubble.removeFromSuperview()
            pokeball.removeFromSuperview()
        })
    }
}
