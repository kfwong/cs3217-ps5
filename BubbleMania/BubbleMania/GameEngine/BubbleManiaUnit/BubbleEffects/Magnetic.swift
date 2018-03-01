//
//  Magnetic.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class Magnetic: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        // it doesn't explode at all
        return []
    }
    
    func effectOnProjectileMovement(_ itself: GameBubble, projectile: GameProjectile) -> (CGFloat, CGFloat) {
        let distance: CGFloat = max(projectile.distance(to: itself.center), 10)
        
        //let massBubble: CGFloat = 1
        //let massProjectile: CGFloat = 1
        
        let gravitationalConstant: CGFloat = 50
        
        //let xUnitVector = (projectile.xPos - itself.xPos) / (distance)
        //let yUnitVector = (projectile.yPos - itself.yPos) / (distance)
        
        let dx = (projectile.xPos - itself.xPos)
        let dy = (projectile.yPos - itself.yPos)
        
        let theta = atan2(dy, dx)

        let attractionForce: CGFloat = gravitationalConstant / (distance * distance)
        
        return (attractionForce, theta - CGFloat.pi / 2)
    }
    
}
