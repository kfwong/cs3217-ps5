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
        let distance: CGFloat = max(projectile.distance(to: itself.center), 30)
        
        /*guard distance < 300 else {
            return (20, 20)
        }*/
        
        //let massBubble: CGFloat = 1
        //let massProjectile: CGFloat = 1
        
        let gravitationalConstant: CGFloat = 140000
        
        //let xUnitVector = (projectile.xPos - itself.xPos) / (distance)
        //let yUnitVector = (projectile.yPos - itself.yPos) / (distance)
        
        let dx = (itself.xPos - projectile.xPos)
        let dy = (itself.yPos - projectile.yPos)
        
        //let theta = atan2(dy, dx)

        let force: CGFloat = -gravitationalConstant / (distance * distance)
        
        //return (attractionForce, theta - CGFloat.pi/2)
        
        return (force * dx / distance, force * dy / distance)
    }
    
}
