//
//  GameBubble.swift
//  GameEngine
//
//  Created by wongkf on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit
import PhysicsEngine

class GameBubble: GameObject, Hexagonal, CollidableCircle {
    internal var row: Int

    internal var col: Int

    internal let bubbleType: BubbleType

    internal let bubbleEffect: BubbleEffectStrategy

    private(set) var hasCollidedWithProjectile: Bool = false

    internal var radius: CGFloat {
        return self.sprite.bounds.width / 2
    }

    init (as sprite: UIView, type: BubbleType, row: Int, col: Int) {
        self.row = row
        self.col = col
        self.bubbleType = type
        self.bubbleEffect = bubbleType.bubbleEffect()

        super.init(as: sprite)
    }

    // return list of gamebubbles exploded by this bubble's effect
    internal func executeExplodeEffect(by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble] {
        return self.bubbleEffect.explode(self, by: projectile, activeBubbles: activeBubbles)
    }

    // it knows how to handle its own exploding animation from its strategy object
    internal func animateExplodeEffect(affectedGameBubbles: [GameBubble]) {
        self.bubbleEffect.explodeAnimation(self, affectedGameBubbles: affectedGameBubbles)
    }

}

extension GameBubble: GameObserver {

    // the GameBubble receive update from GameProjectile when it moves across the screen
    // this is to check if itself is colliding with the projectile
    func receiveUpdate(changesOf observable: GameObservable) {
        if let projectile = observable as? GameProjectile {
            self.hasCollidedWithProjectile = self.isCollidingWith(target: projectile)
        }
    }

}
