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
    static let paletteBubbleTypes: [BubbleType] = [.blue, .red, .orange, .green, .erase, .indestructible, .lightning, .bomb, .star]

    // the raw values corresponds to the image file we use in assets
    case blue = "bubble-blue"
    case red = "bubble-red"
    case orange = "bubble-orange"
    case green = "bubble-green"
    case erase = "bubble-gray"
    case none = "bubble-none"
    case indestructible = "bubble-indestructible"
    case lightning = "bubble-lightning"
    case bomb = "bubble-bomb"
    case star = "bubble-star"

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
    
    // return a strategy object that defines the behaviour of corresponding bubbletype
    func bubbleEffect() -> BubbleEffectStrategy {
        switch self {
        case .blue, .red, .orange, .green: return Normal()
        case .indestructible: return Indestructable()
        case .lightning: return Lightning()
        case .bomb: return Bomb()
        case .star: return Star()
        default: return Normal()
        }
    }
    
    // some special bubbles are associated with normal colored bubble type,
    // therefore they can only be triggered by same colored bubble.
    // this method resolve the root type of this special bubble
    // use in getConnectedGameBubbles() in gameEngine
    //
    // if it's normal colored type, then this method simply return itself
    //
    // if the special bubble does not associate itself with any color, then it simply return itself,
    // gameEngine should handle the logic to resolve the effect
    func bubbleRootType() -> BubbleType {
        switch self {
        case .indestructible: return .indestructible // indestructible type does not have a root type
        case .lightning: return .orange // lightning associates with orange
        case .bomb: return .red // bomb associates with red
        case .star: return .star // star bubble depends on the projectile that came in contact to it, need to resolve independently
        default: return self
        }
    }

    static func randomInGameBubbleType() -> BubbleType {
        let randomIndex = Int(arc4random_uniform(UInt32(BubbleType.inGameBubbleTypes.count)))
        return BubbleType.inGameBubbleTypes[randomIndex]
    }
}
