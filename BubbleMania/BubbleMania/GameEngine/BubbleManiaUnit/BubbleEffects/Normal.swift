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

    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        // does not affect any other gamebubbles
        return []
    }

    // normal explode animation will poof then show a pokeball as "captured"
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble]) {
        guard let bubbleCell = itself.sprite as? BubbleCell else {
            return
        }

        // Note to TA: I know there are many "magic numbers", but I think its best to leave them in context for clarity
        let burstingBubble = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "bubble-burst"), rowCount: 1, colCount: 4, idleSpriteIndex: IndexPath(item: 3, section: 0), animationDuration: 0.25)
        burstingBubble.center = itself.sprite.center
        itself.sprite.superview?.addSubview(burstingBubble)

        let pokeball = UIImageView(image: #imageLiteral(resourceName: "pokeball"))
        pokeball.alpha = 0
        pokeball.center = itself.sprite.center
        pokeball.transform = CGAffineTransform(scaleX: 0, y: 0)
        itself.sprite.superview?.addSubview(pokeball)

        let animationDuration = 1.1
        let animationDelay: Double = 0
        let relativeStartTime = [0, 0.2, 0.4, 0.9]
        let relativeDurations = [0.2, 0.2, 0.5, 0.2]

        UIView.animateKeyframes(withDuration: animationDuration, delay: animationDelay, options: .calculationModeLinear, animations: {
            // fade out and minimize pokemon, start the poof effect
            UIView.addKeyframe(withRelativeStartTime: relativeStartTime[0], relativeDuration: relativeDurations[0]) {
                bubbleCell.bubbleImage.alpha = 0
                bubbleCell.bubbleImage.layer.borderWidth = 0
                bubbleCell.bubbleImage.layer.borderColor = UIColor.clear.cgColor
                bubbleCell.transform = CGAffineTransform(scaleX: 0, y: 0)
                bubbleCell.backgroundColor = UIColor.white

                burstingBubble.startAnimating()
                burstingBubble.alpha = 0
            }

            // fade in and maximize pokeball
            UIView.addKeyframe(withRelativeStartTime: relativeStartTime[1], relativeDuration: relativeDurations[1]) {
                pokeball.alpha = 1
                pokeball.transform = CGAffineTransform(scaleX: 1, y: 1)
            }

            UIView.addKeyframe(withRelativeStartTime: relativeStartTime[2], relativeDuration: relativeDurations[2]) {
                // delay so the pokeball does not disappear immediately
            }

            // fade out pokeball
            UIView.addKeyframe(withRelativeStartTime: relativeStartTime[3], relativeDuration: relativeDurations[3]) {
                pokeball.alpha = 0
            }

        }, completion: { isFinished in
            guard isFinished else {
                return
            }

            // restore the bubbleCell before transformation
            bubbleCell.bubbleImage.transform = CGAffineTransform.identity
            bubbleCell.transform = CGAffineTransform.identity
            bubbleCell.bubbleType = .none

            // remove intermediate UIs
            burstingBubble.removeFromSuperview()
            pokeball.removeFromSuperview()
        })
    }
}
