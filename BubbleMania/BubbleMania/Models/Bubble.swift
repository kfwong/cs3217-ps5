//
//  Bubble.swift
//  LevelDesigner
//
//  Created by wongkf on 4/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 The Bubble model stores the type and the position of itself in the grid.
 Use in encoding/decoding game level state.
 */
class Bubble: Codable {
    var type: BubbleType
    let xIndex: Int
    let yIndex: Int

    convenience init(bubbleType type: BubbleType = .erase, indexPathInBubbleGrid indexPath: IndexPath) {
        self.init(bubbleType: type, xIndex: indexPath.item, yIndex: indexPath.section)
    }

    init(bubbleType type: BubbleType = .erase, xIndex: Int, yIndex: Int) {
        self.type = type
        self.xIndex = xIndex
        self.yIndex = yIndex
    }
}

/**
 The enumeration BubbleType serves as representation of every bubble type in the game.
 It also serves as Finite State Machine that is being used in the "tapping+cycle bubble brush" feature.
 */
enum BubbleType: String, Codable {

    static let inGameBubbleTypes: [BubbleType] = [.blue, .red, .orange, .green]

    // the raw values corresponds to the image file we use in assets
    case blue = "bubble-blue"
    case red = "bubble-red"
    case orange = "bubble-orange"
    case green = "bubble-green"
    case erase = "bubble-gray"
    case none = "bubble-none"

    // Simple Finite State Machine that transition from one state to another
    func next() -> BubbleType {
        switch self {
        case .blue: return .red
        case .red: return .orange
        case .orange: return .green
        case .green: return .erase
        case .erase: return .blue
        default: return .none
        }
    }

    static func randomInGameBubbleType() -> BubbleType {
        let randomIndex = Int(arc4random_uniform(UInt32(BubbleType.inGameBubbleTypes.count)))
        return BubbleType.inGameBubbleTypes[randomIndex]
    }
}
