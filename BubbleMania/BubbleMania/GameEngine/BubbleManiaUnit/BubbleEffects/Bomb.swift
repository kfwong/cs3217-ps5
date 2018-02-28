//
//  Bomb.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// Bomb bubbles destroy all bubbles adjacent to itself
class Bomb: BubbleEffectStrategy {
    func explode(_ itself: GameBubble, by projectile: GameProjectile, activeBubbles: [GameBubble]) -> [GameBubble]{
        print("\(itself.row):\(itself.col) exploded with bomb effect")
        
        // gamebubble can calculate the neighbour index in a hexagon grid
        let affectedIndexes = itself.neighbourIndexes()
        
        // filter active bubbles to leave only those adjacent to this gamebubble
        return activeBubbles.filter{ affectedIndexes.contains(IndexPath(item: $0.col, section: $0.row))}
        
    }
}
