//
//  CollisionStrategy.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit

// Gives properties to check if a circle is colliding with another or screen edge with reference to self
public protocol CollidableCircle {
    var xPos: CGFloat { get }
    var yPos: CGFloat { get }
    var radius: CGFloat { get }

    func isCollidingWith(target: CollidableCircle) -> Bool
    func isCollidingWithScreenSideEdge(edgeOffset: CGFloat) -> Bool
    func isCollidingWithScreenTopEdge() -> Bool
}

// default implementation for GameObject
extension CollidableCircle where Self: GameObject {

    // uses pythogaras theorem to check if two circles collide
    public func isCollidingWith(target: CollidableCircle) -> Bool {
        let xDiff = target.xPos - self.xPos
        let yDiff = target.yPos - self.yPos

        let radii = target.radius + self.radius

        // square them instead of taking square root to optimize computation
        return (xDiff * xDiff) + (yDiff * yDiff) < (radii * radii)
    }

    // offset by radius pixels so it does not appear to penetrate the edge
    // can also supply optional edgeOffset
    public func isCollidingWithScreenSideEdge(edgeOffset: CGFloat = 10) -> Bool {
        return self.xPos <= self.radius + edgeOffset ||
            (self.xPos + self.radius) >= UIScreen.main.bounds.width - edgeOffset
    }

    // offset by radius pixels so it does not appear to penetrate the edge
    public func isCollidingWithScreenTopEdge() -> Bool {
        return self.yPos <= self.radius
    }
}
