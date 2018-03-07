//
//  Magnetic.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class Magnetic: BubbleEffectStrategy {

    private(set) var isDestructible: Bool = false

    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        // it doesn't explode at all
        return []
    }

    func effectOnProjectileMovement(_ itself: GameBubble, projectile: GameProjectile) -> (CGFloat, CGFloat) {
        // to prevent divide by zero
        let distance: CGFloat = max(projectile.distance(to: itself.center), 30)

        let gravity: CGFloat = 140_000

        let dx = (itself.xPos - projectile.xPos)
        let dy = (itself.yPos - projectile.yPos)

        let force: CGFloat = -gravity / (distance * distance)

        return (force * dx / distance, force * dy / distance)
    }

}
