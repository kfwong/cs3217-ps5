//
//  Star.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

// Star bubbles destroy all bubbles of same type on the entire grid
class Star: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        print("\(itself.row):\(itself.col) exploded with star effect")

        // filter the list of gamebubbles of same type as the projectile
        return activeBubbles.filter{ $0.bubbleType == projectile.bubbleType}
    }
}


