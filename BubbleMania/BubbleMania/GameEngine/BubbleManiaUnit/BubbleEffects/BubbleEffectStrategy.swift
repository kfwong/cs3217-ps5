//
//  BubbleEffectStrategy.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

protocol BubbleEffectStrategy {
    
    // when executing explode, this method should return a list of affected bubbles
    // itself: the gamebubble itself
    // projectile: the projectile that trigger the effect
    // activeBubbles: current active bubbles in the arena
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]
    
    // define the animation when this bubble explodes
    func explodeAnimation(_ itself: GameBubble)
}
