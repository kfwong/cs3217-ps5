//
//  Indestructable.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

// NOTE: this class exists for completeness
class Indestructable: BubbleEffectStrategy {
    
    private(set) var isDestructible: Bool = false
    
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        // Indestructable bubbles has no effect when exploding
        // wts it doesn't even explode at all :/
        return []
    }
    
    // explode animation is not applicable, inherit default implementation (which does nothing)
}

