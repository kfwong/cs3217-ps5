//
//  Projectile.swift
//  GameEngine
//
//  Created by wongkf on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit
import PhysicsEngine
import Foundation

class GameProjectile: GameObject, Geometrical, CollidableCircle {

    internal var radius: CGFloat

    internal var thrust: CGFloat

    internal var isReflected: Bool

    internal var prevBearing: CGFloat?

    internal var force: (CGFloat, CGFloat) {
        // if there are multiple magnetic forces, add their vectors
        return gameBubbleObservers
            .filter { $0.bubbleType == .magnetic }
            .map { $0.bubbleEffect.effectOnProjectileMovement($0, projectile: self) }
            .reduce((0, 0)) { accum, force in (accum.0 + force.0, accum.1 + force.1) }
    }

    private(set) var gameBubbleObservers: Set<GameBubble>

    private let minBearing = CGFloat.pi / 8
    private let maxBearing = 7 * CGFloat.pi / 8
    private let cutOffBearing = CGFloat.pi / 2

    internal var bubbleType: BubbleType {
        willSet(bubbleType) {
            if let imageView = self.sprite as? UIImageView {
                imageView.image = UIImage(named: bubbleType.rawValue)
            }
        }
    }

    init(bubbleType: BubbleType, size: CGSize) {
        let sprite = UIImageView(image: UIImage(named: bubbleType.rawValue))
        sprite.bounds.size = size

        self.radius = sprite.bounds.width / 2
        self.thrust = 1
        self.bubbleType = bubbleType
        self.isReflected = false

        self.gameBubbleObservers = []

        super.init(as: sprite)
    }

    convenience init(size: CGSize) {
        self.init(bubbleType: .randomInGameBubbleType(), size: size)
    }

    // for projectile to move. It also do reflection when it hits the screen edge
    internal func fire(bearing: CGFloat) {
        // the computed value scan through all magnetic bubble in O(n) time
        // we compute once and store the value instead of recompute everytime we need it
        let theforce = force

        // force return tuple: (x-component, y-component)
        self.sprite.center.x -= theforce.0 + (isReflected ? -(thrust) * cos(bearing): (thrust) * cos(bearing))
        self.sprite.center.y -= theforce.1 + (thrust) * sin(bearing)

        checkReflection()

        notify()
    }

    // calculte restricted angle
    internal func normalizeBearing(_ bearing: CGFloat) -> CGFloat {
        guard !(bearing >= minBearing && bearing <= maxBearing) else {
            return bearing
        }

        return (bearing >= 0 && bearing < minBearing) || (bearing < 0 && bearing >= -cutOffBearing) ? minBearing : maxBearing

    }

    // flip the bit x-component if collide with screen edge
    internal func checkReflection() {
        if isCollidingWithScreenSideEdge() {
            self.isReflected = !self.isReflected
        }
    }

    // compile all game bubbles' state to check if itself is colliding with any bubble
    internal func hasCollidedWithGameBubble() -> Bool {
        return gameBubbleObservers.reduce(false) {hasCollided, gameBubble in
            return hasCollided || gameBubble.hasCollidedWithProjectile
        }
    }
}

extension GameProjectile: GameObservable {
    func notify() {
        self.gameBubbleObservers.forEach { $0.receiveUpdate(changesOf: self) }
    }

    func attach<T>(observer: T) where T: GameObserver, T: Hashable {
        guard let gameBubble = (observer as? GameBubble) else {
            return
        }

        self.gameBubbleObservers.insert(gameBubble)
    }

    func detach<T>(observer: T) where T: GameObserver, T: Hashable {
        guard let gameBubble = (observer as? GameBubble) else {
            return
        }

        self.gameBubbleObservers.remove(gameBubble)
    }

    func detachAll() {
        self.gameBubbleObservers.removeAll()
    }

}
