//
//  PhysicsObject.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit
import Foundation

// allows an object to calculate all geometrical/trigometric functions with reference to self
public protocol Geometrical {
    var xPos: CGFloat { get }
    var yPos: CGFloat { get }

    func verticalAngleFromSelf(to: CGPoint) -> CGFloat
    func distance(to: CGPoint) -> CGFloat

}

extension Geometrical where Self: GameObject {

    // return the angle between horizontal x-axis and line form by this object center to target point
    public func verticalAngleFromSelf (to: CGPoint) -> CGFloat {
        let xComponent = self.xPos - to.x
        let yComponent = self.yPos - to.y

        return atan2(yComponent, xComponent)
    }
    
    public func distance(to: CGPoint) -> CGFloat {
        let xComponent = self.xPos - to.x
        let yComponent = self.yPos - to.y
        
        return sqrt(xComponent * xComponent + yComponent * yComponent)
    }

}
