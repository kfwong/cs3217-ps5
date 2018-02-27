//
//  Hexagon.swift
//  LevelDesigner
//
//  Created by wongkf on 16/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

// An object that is packed in Hexagonal Grid can find their neighbour indexes
public protocol Hexagonal {
    var row: Int { get }
    var col: Int { get }

    func neighbourIndexes() -> [IndexPath]
}

extension Hexagonal where Self: GameObject {

    // precondition: the grid is using odd-r coordinates
    // calculate the neighbour indexes using offset vectors
    // this method assume infinite grid with both positive and negative indexes
    public func neighbourIndexes() -> [IndexPath] {
        let oddRowOffsetVectors = [(0, 1), (-1, 1), (-1, 0), (0, -1), (1, 0), (1, 1)]
        let evenRowOffsetVectors = [(0, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0)]
        let neighbourOffsetVectors = [evenRowOffsetVectors, oddRowOffsetVectors]

        let parity = row & 1

        // take note that the IndexPath row/col are inverted
        return neighbourOffsetVectors[parity].map { IndexPath(item: col + $0.1, section: row + $0.0) }

    }
}
