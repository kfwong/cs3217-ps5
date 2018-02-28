//
//  Normal.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

// this class exists for completeness
class Normal: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        // normal bubbles has no effect when exploding
        print("\(itself.row):\(itself.col) exploded normally")
        
        return []
    }
}
