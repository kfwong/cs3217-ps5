//
//  BubbleEffectStrategy.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

protocol BubbleEffectStrategy {
    
    var isDestructible: Bool { get }
    
    // when executing explode, this method should return a list of affected bubbles
    // itself: the gamebubble itself
    // projectile: the projectile that trigger the effect
    // activeBubbles: current active bubbles in the arena
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]
    
    // define the animation when this bubble explodes
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble])
    
    // the effect on projectile movement should return a force of x-component and y-component in a tuple
    func effectOnProjectileMovement(_ itself: GameBubble, projectile: GameProjectile) -> (CGFloat, CGFloat)
}

extension BubbleEffectStrategy {
    // default implementation
    // so that classes that conforms to this protocol only have to override on-demand
    
    // I did not include default implementation for explode() because it's best to leave it explicit in thier respective concrete class for clarity
    
    func explodeAnimation(_ itself: GameBubble, affectedGameBubbles: [GameBubble]) {
        // by default there's no animation
    }
    
    func effectOnProjectileMovement(_ itself: GameBubble, projectile: GameProjectile) -> (CGFloat, CGFloat){
        // by default it does not affect projectile's movement while firing
        return (0, 0)
    }
}
