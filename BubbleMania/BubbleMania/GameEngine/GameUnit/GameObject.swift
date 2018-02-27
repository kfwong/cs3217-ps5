//
//  GameObject.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import UIKit

/**
 GameObject holds the common properties required by various Physics protocol.
 It also conform to Hashable to alow uniquely identify each object
 */
class GameObject {

    internal var xPos: CGFloat {
        return self.sprite.center.x
    }
    internal var yPos: CGFloat {
        return self.sprite.center.y
    }

    internal var center: CGPoint {
        return self.sprite.center
    }

    internal var sprite: UIView

    init (as sprite: UIView) {
        self.sprite = sprite
    }
}

extension GameObject: Hashable {

    var hashValue: Int {
        return self.sprite.hashValue
    }

    static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs.sprite == rhs.sprite
    }
}
