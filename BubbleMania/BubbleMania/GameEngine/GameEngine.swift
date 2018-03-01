//
//  GameEngine.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import Foundation
import UIKit

/**
 GameEngine handles high level logical actions that the game should take.
 */
class GameEngine {
    weak var delegate: GameLoopDelegate?

    // need to init with dummy size because I don't want to deal with optional
    // bubbleSize is only available after viewDidLoad in controller,
    // so passing param in init propagate the optional up to the controller which makes the code very ugly
    private(set) var projectile: GameProjectile = GameProjectile(size: CGSize(width: 1, height: 1))
    private(set) var bubbles: Set<GameBubble> = []
    private(set) var cannon: GameCannon?
    private(set) var lastShot: GameBubble?
    private(set) var upcomingBubbles: Queue<BubbleType> = Queue()

    private(set) var bearing: CGFloat?
    private(set) var cannonInitialAngle: CGFloat = CGFloat.pi/2
    private(set) var cannonDeltaAngle: CGFloat = 0

    private let sectionCount: Int
    private let oddSectionBubbleCount: Int

    private(set) var gameState: GameState = .loadGame
    
    private(set) var upcomingBubbleCount = 1

    init(sectionCount: Int, oddSectionBubbleCount: Int) {
        self.sectionCount = sectionCount
        self.oddSectionBubbleCount = oddSectionBubbleCount
    }

    internal func updateGameLoop() {
        self.delegate?.onGameLoopUpdate()
    }

    internal func loadGame() {
        self.gameState = .loadGame
    }

    internal func newGame() {
        self.gameState = .newGame
    }

    internal func loadProjectile(gameContext: UIView, size: CGSize) {

        self.gameState = .loadingProjectile
        
        loadUpcomingBubbles()
        
        print("loading projectile")
        
        guard let nextBubble = upcomingBubbles.dequeue() else {
            fatalError("Game Engine error. Can't pop the upcoming bubble!")
        }

        let projectileMountPoint = getProjectileMountPoint()
        
        // check if the projectile has already been initialized with proper size
        // guard is not appropriate here because it force throw/return to function, cannot fallthrough; if-else too verbose, so ternary is the best choice
        self.projectile = self.projectile.sprite.bounds.size == CGSize(width: 1, height: 1) ? GameProjectile(size: size) : self.projectile
        self.projectile.bubbleType = nextBubble
        self.projectile.sprite.center.x = projectileMountPoint.x
        self.projectile.sprite.center.y = projectileMountPoint.y
        self.projectile.thrust = 20
        self.projectile.isReflected = false
        self.projectile.sprite.isHidden = false

        if !(self.projectile.sprite.isDescendant(of: gameContext)) {
            gameContext.addSubview(self.projectile.sprite)
        }

    }

    internal func loadingProjectileComplete() {
        self.gameState = .loadingProjectileComplete
        
        loadUpcomingBubbles()
    }

    internal func settingProjectileBearing(to bearing: CGPoint) {
        self.gameState = .settingProjectileBearing

        print("adjusting projectile bearing")

        self.bearing = self.projectile.verticalAngleFromSelf(to: bearing)
        
        guard let cannon = self.cannon else {
            return
        }
        
        self.cannonDeltaAngle = cannon.verticalAngleFromSelf(to: bearing) - self.cannonInitialAngle
    }

    internal func settingProjectileBearingComplete(to bearing: CGPoint) {
        self.bearing = self.projectile.verticalAngleFromSelf(to: bearing)

        self.gameState = .settingProjectileBearingComplete
    }

    internal func firingProjectile() {
        self.gameState = .firingProjectile

        // do some firing
        print("firing projectile")

        guard let angle = self.bearing else {
            return
        }

        self.projectile.fire(bearing: angle)
    }

    internal func firingProjectileComplete() {
        self.gameState = .firingProjectileComplete
    }

    // get the middle point of screen
    internal func getProjectileMountPoint() -> CGPoint {
        let mountPointX = UIScreen.main.bounds.midX
        let mountPointY = UIScreen.main.bounds.height

        return CGPoint(x: mountPointX, y: mountPointY - 100)
    }

    // virtually add an active gamebubble into gameEngine
    internal func addActiveGameBubble(_ gameBubble: GameBubble) {
        self.bubbles.insert(gameBubble)
        self.projectile.attach(observer: gameBubble)
    }

    // virtually remove an active gamebubble from gameEngine
    internal func removeActiveGameBubble(_ gameBubble: GameBubble) {
        self.bubbles.remove(gameBubble)
        self.projectile.detach(observer: gameBubble)
    }

    internal func removeAllActiveGameBubbles() {
        self.bubbles.removeAll()
        self.projectile.detachAll()
    }

    internal func snappingToPoint() {
        self.gameState = .snappingToPoint
    }

    internal func snappingToPointComplete(lastShot: GameBubble) {
        self.lastShot = lastShot
        self.projectile.sprite.isHidden = true
        self.gameState = .snappingToPointComplete
    }

    internal func executingEffect() {
        self.gameState = .executingEffect
    }

    internal func executingEffectComplete() {
        self.gameState = .executingEffectComplete
    }
    internal func detachingDisconnectedGameBubbles() {
        self.gameState = .detachingDisconnectedGameBubbles
    }

    internal func detachingDisconnectedGameBubblesComplete() {
        self.gameState = .detachingDisconnectedGameBubblesComplete
    }

    internal func animating() {
        self.gameState = .animating
    }

    internal func resetGame() {
        self.removeAllActiveGameBubbles()
        self.newGame()
    }

    // return valid neighbour indexes given the grid size.
    internal func neighbourIndexes(of gameBubble: GameBubble) -> [IndexPath] {
        let maxEvenRowIndex = oddSectionBubbleCount
        let maxOddRowIndex = oddSectionBubbleCount - 1
        let maxRowsIndex = sectionCount - 1

        return gameBubble.neighbourIndexes()
            .filter {
                let isNegativeIndex = $0.item < 0 || $0.section < 0
                let hasExceededEvenRowIndex = ($0.section & 1 == 0) && $0.item > maxEvenRowIndex
                let hasExceededOddRowIndex = ($0.section & 1 == 1) && $0.item > maxOddRowIndex
                let hasExceededMaxRows = $0.section > maxRowsIndex

                return !(isNegativeIndex || hasExceededEvenRowIndex || hasExceededOddRowIndex || hasExceededMaxRows)
            }
    }

    // return active gamebubbles in game that is also neighbour of target game bubble
    internal func getActiveNeighours(of gameBubble: GameBubble) -> [GameBubble] {

        // Need: indexes of in-game bubbles in grid
        // gameEngine keep tracks of active bubbles in game,
        // so we can use it and transform them into active IndexPaths
        let activeBubbleIndexes = self.bubbles.map { IndexPath(item: $0.col, section: $0.row) }

        // gameBubble knows how to calculcate their neighbour's indexes (see: Hexagonal protocol)
        // by doing cross comparison with active bubble indexes, we can filter out inactive neighbour indexes
        let activeNeighbourIndexes = neighbourIndexes(of: gameBubble).filter { activeBubbleIndexes.contains($0) }

        // transform active indexes into GameBubbles
        let activeNeighbours = self.bubbles.filter { activeNeighbourIndexes.contains(IndexPath(item: $0.col, section: $0.row)) }

        return Array(activeNeighbours)
    }

    // return list of connected bubble from source.
    // can also alter behaviour of this method to find only the connected bubbles of same type.
    internal func getConnectedGameBubbles(ofSameType: Bool = false, from source: GameBubble) -> [GameBubble] {
        var queue = Queue<GameBubble>()
        var visited: Set<GameBubble> = []

        queue.enqueue(source)
        visited.insert(source)

        while let next = queue.dequeue() {
            let neighbours = getActiveNeighours(of: next)

            neighbours.forEach {
                // check if bubble has been visited before
                guard !visited.contains($0) else {
                    return
                }

                // 1. we don't care if they are the same kind
                // 2. we want the same kind and the bubble type matches
                if !ofSameType || (ofSameType && $0.bubbleType.bubbleRootType() == source.bubbleType.bubbleRootType()) {
                    queue.enqueue($0)
                    visited.insert($0)
                }

            }
        }

        return Array(visited)
    }

    // list all disconnected active gamebubbles from top row
    internal func getDisconnectedGameBubbles() -> [GameBubble] {

        // get only active top row game bubbles (empty top cells are ignored)
        let topRowGameBubbles = self.bubbles.filter { $0.row == 0 }

        let connectedGameBubbles = topRowGameBubbles.map { getConnectedGameBubbles(from: $0) } // transform each top bubble into list of its connected cells
                                                    .flatMap { $0 } // flatten 2D array to 1D array

        return self.bubbles.filter { !connectedGameBubbles.contains($0) } // activeGameBubbles - connectedGameBubbles = disconnectedGameBubbles

    }
    
    internal func setupCannon(as sprite: UIView){
        self.cannon = GameCannon(as: sprite)
    }
    
    internal func loadUpcomingBubbles() {
        while upcomingBubbles.count < upcomingBubbleCount {
            upcomingBubbles.enqueue(BubbleType.randomInGameBubbleType())
        }
    }
    
    internal func explodeBubbles(gameBubbles: [GameBubble]) {
        for gameBubble in gameBubbles {
            guard self.bubbles.contains(gameBubble) else {
                continue
            }
            
            // first we must remove this gamebubble from game engine state to prevent infinite loop in recursion
            removeActiveGameBubble(gameBubble)
            gameBubble.animateExplodeEffect()
            
            // use recursion to simulate chain reaction
            let chainReaction = gameBubble.executeExplodeEffect(by: self.projectile, activeBubbles: Array(self.bubbles))
            explodeBubbles(gameBubbles: chainReaction)
        }
    }
}

protocol GameLoopDelegate: class {
    func onGameLoopUpdate()
}

enum GameState {
    case loadGame
    case newGame
    case loadingProjectile
    case loadingProjectileComplete
    case settingProjectileBearing
    case settingProjectileBearingComplete
    case firingProjectile
    case firingProjectileComplete
    case snappingToPoint
    case snappingToPointComplete
    case executingEffect
    case executingEffectComplete
    case detachingDisconnectedGameBubbles
    case detachingDisconnectedGameBubblesComplete
    case animating
    case gameOver
}
