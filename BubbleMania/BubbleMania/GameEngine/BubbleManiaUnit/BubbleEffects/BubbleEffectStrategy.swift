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
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]
    
}
