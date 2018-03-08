//
//  GameController+GameEngine.swift
//  LevelDesigner
//
//  Created by wongkf on 17/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

// contains the game logic
extension GameController: GameLoopDelegate {
    internal func onGameLoopUpdate() {
        switch self.gameEngine.gameState {

        case .loadGame:
            gameEngine.loadProjectile(gameContext: self.view, size: bubbleSize)
            recoverLevelData()
            gameEngine.loadingProjectileComplete()
            self.view.bringSubview(toFront: cannon)
            self.view.bringSubview(toFront: canonBase)
            gameEngine.setupCannon(as: cannon)

            loadUpcomingBubble()

        case .newGame:
            gameEngine.loadProjectile(gameContext: self.view, size: bubbleSize)
            gameEngine.loadingProjectileComplete()
            self.view.bringSubview(toFront: cannon)
            self.view.bringSubview(toFront: canonBase)
            gameEngine.setupCannon(as: cannon)

            loadUpcomingBubble()

        case .firingProjectile:
            if gameEngine.projectile.isCollidingWithScreenTopEdge() || gameEngine.projectile.hasCollidedWithGameBubble() {
                gameEngine.firingProjectileComplete()
                gameEngine.snappingToPoint()
            } else {
                gameEngine.firingProjectile()
            }

        case .snappingToPoint:
            gameEngine.animating()
            animateSnapProjectileToNearestCell { gameBubble in
                self.gameEngine.snappingToPointComplete(lastShot: gameBubble)
                self.gameEngine.executingEffect()
            }

        case .executingEffect:
            guard let projectile = self.gameEngine.lastShot else {
                return
            }

            // resolve any crowding bubbles of same type
            let connectedGameBubblesOfSameType = gameEngine.getConnectedGameBubbles(ofSameType: true, from: projectile)
            if connectedGameBubblesOfSameType.count >= 3 {
                gameEngine.animating()
                gameEngine.explodeBubbles(gameBubbles: connectedGameBubblesOfSameType)
            }

            // resolve any neighbouring star bubbles
            let starBubbleNeighbours = gameEngine.getActiveNeighours(of: projectile)
                                                 .filter { $0.bubbleType.bubbleRootType() == .star }
            gameEngine.animating()
            gameEngine.explodeBubbles(gameBubbles: starBubbleNeighbours)

            self.gameEngine.executingEffectComplete()
            self.gameEngine.detachingDisconnectedGameBubbles()

        case .detachingDisconnectedGameBubbles:
            let disconnectedGameBubbles = gameEngine.getDisconnectedGameBubbles()

            gameEngine.animating()

            let snapshots = createGameBubbleSnapshots(gameBubbles: disconnectedGameBubbles)
            snapshots.forEach { self.bubbleGrid.addSubview($0) }

            disconnectedGameBubbles.forEach {
                guard let bubbleCell = ($0.sprite as? BubbleCell) else {
                    return
                }

                bubbleCell.bubbleType = .none
            }

            executeDetachEffect(sprites: snapshots) {
                disconnectedGameBubbles.forEach { self.gameEngine.removeActiveGameBubble($0) }

                snapshots.forEach { $0.removeFromSuperview() }

                self.gameEngine.detachingDisconnectedGameBubblesComplete()
            }

        case .detachingDisconnectedGameBubblesComplete:
            if gameEngine.hasClearedAllActiveBubbles() {
                self.gameEngine.gameClear()
                self.showGameClearedDialog {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.gameEngine.newGame()
            }
        default: return
        }
    }

    // Deselect any brushes when user tap on gray palette area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {

            switch gameEngine.gameState {

            case .loadingProjectileComplete:
                let bearing = touch.location(in: self.view)

                guard !isRestrictedAngle(bearing: bearing) else {
                    return
                }

                gameEngine.settingProjectileBearing(to: bearing)

                rotateCannon(deltaRadian: self.gameEngine.cannonDeltaAngle)

            default: return
            }

        }

    }

    // allow adjustment of angle as long as the finger is not lifting up
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            switch gameEngine.gameState {

            case .settingProjectileBearing:
                let bearing = touch.location(in: self.view)

                guard !isRestrictedAngle(bearing: bearing) else {
                    return
                }

                gameEngine.settingProjectileBearing(to: bearing)

                rotateCannon(deltaRadian: self.gameEngine.cannonDeltaAngle)

            default: return
            }

        }
    }

    // set the angle into gameEngine when finger is lifed.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            switch gameEngine.gameState {

            case .settingProjectileBearing:
                let bearing = touch.location(in: self.view)

                gameEngine.settingProjectileBearingComplete(to: isRestrictedAngle(bearing: bearing) ? CGPoint(x: bearing.x, y: gameEngine.projectile.yPos - 50) : bearing)

                rotateCannon(deltaRadian: self.gameEngine.cannonDeltaAngle) {
                    // on rotate animation complete, do these:
                    self.animateCannonBurst()
                    self.gameEngine.firingProjectile()
                }
            default: return
            }

        }
    }
}
