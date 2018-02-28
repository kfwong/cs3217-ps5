//
//  Projectile.swift
//  GameEngine
//
//  Created by wongkf on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit
import PhysicsEngine

class GameProjectile: GameObject, Geometrical, CollidableCircle {

    internal var radius: CGFloat

    internal var thrust: CGFloat

    internal var isReflected: Bool

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
        let normalizedBearing = normalizeBearing(bearing)

        self.sprite.center.x -= isReflected ? -thrust * cos(normalizedBearing): thrust * cos(normalizedBearing)
        self.sprite.center.y -= thrust * sin(normalizedBearing)

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

    // snapping to point with animation.
    internal func snapToPoint(at: CGPoint, onAnimateComplete: (() -> Void)? = nil) {
        let deltaX = at.x - self.xPos
        let deltaY = at.y - self.yPos

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                            self.sprite.transform = CGAffineTransform(translationX: deltaX, y: deltaY)
                        }, completion: { _ in
                            onAnimateComplete?()
                            self.sprite.transform = CGAffineTransform.identity
                        })
    }

    // the projectile also can define how the detach animations are. can be converted into one of the projectile strategy object.
    internal func executeDetachEffect(sprites: [UIView], onAnimateComplete: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                            sprites.forEach {
                                $0.alpha = 0
                                $0.transform = CGAffineTransform(translationX: 0, y: 300)
                            }
                        }, completion: { _ in
                            onAnimateComplete?()
                        })
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
