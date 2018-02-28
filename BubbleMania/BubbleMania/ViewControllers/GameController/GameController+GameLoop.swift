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
            self.view.bringSubview(toFront: a)
            self.view.bringSubview(toFront: canonBase)

        case .newGame:
            gameEngine.loadProjectile(gameContext: self.view, size: bubbleSize)
            gameEngine.loadingProjectileComplete()
            self.view.bringSubview(toFront: a)
            self.view.bringSubview(toFront: canonBase)

        case .firingProjectile:
            if gameEngine.projectile.isCollidingWithScreenTopEdge() || gameEngine.projectile.hasCollidedWithGameBubble() {
                gameEngine.firingProjectileComplete()
                gameEngine.snappingToPoint()
            } else {
                gameEngine.firingProjectile()
            }

        case .snappingToPoint:
            gameEngine.animating()
            snapProjectileToNearestCell { gameBubble in
                self.gameEngine.snappingToPointComplete(lastShot: gameBubble)
                self.gameEngine.executingEffect()
            }

        case .executingEffect:
            guard let lastProjectile = self.gameEngine.lastShot else {
                return
            }

            let connectedGameBubblesOfSameType = gameEngine.getConnectedGameBubbles(ofSameType: true, from: lastProjectile)

            if connectedGameBubblesOfSameType.count >= 3 {
                gameEngine.animating()
                gameEngine.projectile.executeEffect(gameBubbles: connectedGameBubblesOfSameType) {
                    connectedGameBubblesOfSameType.forEach {
                        guard let bubbleCell = ($0.sprite as? BubbleCell) else {
                            return
                        }

                        $0.sprite.alpha = 1
                        bubbleCell.bubbleType = .none
                        self.gameEngine.removeActiveGameBubble($0)
                    }

                    self.gameEngine.executingEffectComplete()
                    self.gameEngine.detachingDisconnectedGameBubbles()
                }
            } else {
                self.gameEngine.executingEffectComplete()
                self.gameEngine.detachingDisconnectedGameBubbles()
            }

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

            gameEngine.projectile.executeDetachEffect(sprites: snapshots) {
                disconnectedGameBubbles.forEach { self.gameEngine.removeActiveGameBubble($0) }

                snapshots.forEach { $0.removeFromSuperview() }

                self.gameEngine.detachingDisconnectedGameBubblesComplete()
            }

        case .detachingDisconnectedGameBubblesComplete:
            gameEngine.newGame()

        default: return
        }
    }

    
    // Deselect any brushes when user tap on gray palette area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {

            switch gameEngine.gameState {

            case .loadingProjectileComplete:
                let bearing = touch.location(in: self.view)
                
                let deltaAngle = verticalAngleFromSelf(xPos: self.a.center.x, yPos: self.a.center.y, to: bearing) - self._angle
                
                UIView.animate(withDuration: 0.25,
                               delay: 0,
                               options: UIViewAnimationOptions.curveEaseIn,
                               animations: { self.a.transform = CGAffineTransform(rotationAngle: deltaAngle) },
                               completion: nil)
                
                gameEngine.settingProjectileBearing(to: bearing)

            default: return
            }

        }

    }
    
    public func verticalAngleFromSelf (xPos:CGFloat, yPos: CGFloat, to: CGPoint) -> CGFloat {
        let xComponent = xPos - to.x
        let yComponent = yPos - to.y
        
        return atan2(yComponent, xComponent)
    }

    // allow adjustment of angle as long as the finger is not lifting up
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            switch gameEngine.gameState {

            case .settingProjectileBearing:
                let bearing = touch.location(in: self.view)
                
                let deltaAngle = verticalAngleFromSelf(xPos: self.a.center.x, yPos: self.a.center.y, to: bearing) - self._angle
                
                self.a.transform = CGAffineTransform(rotationAngle: deltaAngle)
                
                gameEngine.settingProjectileBearing(to: bearing)

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
                gameEngine.settingProjectileBearingComplete(to: bearing)
                 a.startAnimating()
                gameEngine.firingProjectile()

            default: return
            }

        }
    }
}
