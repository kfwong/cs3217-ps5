//
//  Indestructable.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

// this class exists for completeness
class Indestructable: BubbleEffectStrategy {
    
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        // Indestructable bubbles has no effect when exploding
        // wts it doesn't even explode at all :/
        
        return []
    }
    
    func explodeAnimation(_ itself: GameBubble) {
        // nothing to animate
    }
}

