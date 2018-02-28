//
//  GameController.swift
//  LevelDesigner
//
//  Created by wongkf on 13/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
import SpriteKit

// Main GameController handle display Bubbles at correct position in grid
// also define throw away alert ui.
class GameController: UIViewController {
    
    internal var _angle: CGFloat = CGFloat.pi/2

    internal var passedLevelData: [Bubble]?

    internal var levelData: [Bubble] = []

    internal let oddSectionBubbleCount = 11
    internal let evenSectionBubbleCount = 12
    internal let sectionCount = 13

    internal let oddSectionInset = UIEdgeInsets(top: -8, left: 31, bottom: -8, right: 31)
    internal let evenSectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    lazy internal var gameEngine = GameEngine(sectionCount: sectionCount, oddSectionBubbleCount: oddSectionBubbleCount)
    private let gameRenderer = GameRenderer()

    // http://blog.scottlogic.com/2014/11/20/swift-initialisation.html
    // note that we cannot override the init function. (view is not loaded, will crash if access UI variables that is not yet inited)
    // we have to wait for viewDidLoad() so we can calculate the actual size.
    // preferred choice is to use implicit unwrap here (not allowed in cs3217 :/)
    // fallback to lazy initialization until the bubbleDiameter/bubbleSize is first accessed.
    // crash is impossible because loadProjectile() is always triggered after view is loaded. (whitebox)
    lazy private var bubbleDiameter = (self.bubbleGrid.frame.size.width / CGFloat(max(oddSectionBubbleCount, evenSectionBubbleCount)))
    lazy private(set) var bubbleSize: CGSize = CGSize(width: self.bubbleDiameter, height: self.bubbleDiameter)
    
    @IBOutlet weak var canonBase: UIImageView!
    internal var a: UIAnimatedView!

    @IBOutlet private(set) weak var bubbleGrid: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bubbleGrid.isUserInteractionEnabled = false

        self.bubbleGrid.delegate = self

        self.gameEngine.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // need to hook on viewDidAppear because there is racing condition when reloading passed variables into the grid
        // therefore it's safer to start the renderer after the view is fully loaded. (segue and transition complete)
        self.gameRenderer.start(engine: gameEngine)
        
        a = UIAnimatedView(spriteSheet: #imageLiteral(resourceName: "cannon"), rowCount: 2, colCount: 6)
        
        let oldFrame = a.frame
        a.layer.anchorPoint = CGPoint(x:0.5, y: 0.81)
        a.frame = oldFrame
        
        a.center.x = canonBase.frame.midX
        a.center.y = canonBase.frame.midY - canonBase.frame.height/4 + 5
        
        self.view.addSubview(a)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //return the value as per the required orientation
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    // For loading a level into playable game
    internal func recoverLevelData() {
        guard let data = passedLevelData else {
            return
        }

        self.reloadBubbleGrid(bubbles: data)

        for bubble in data {
            guard let cell = self.bubbleGrid.cellForItem(at: IndexPath(item: bubble.yIndex, section: bubble.xIndex)) else {
                return
            }

            guard bubble.type != .none else {
                continue
            }

            let gameBubble = GameBubble(as: cell, type: bubble.type, row: bubble.xIndex, col: bubble.yIndex)

            // need to update gameEngine to track the state
            self.gameEngine.addActiveGameBubble(gameBubble)

        }

    }

    internal func snapProjectileToNearestCell(onSnapComplete: ((_ gameBubble: GameBubble) -> Void)? = nil) {
        let landingPoint = CGPoint(x: gameEngine.projectile.xPos, y: self.gameEngine.projectile.yPos)

        if let nearestCellIndex = bubbleGrid.indexPathForItem(at: landingPoint),
            let nearestCell = bubbleGrid.cellForItem(at: nearestCellIndex) as? BubbleCell {

            gameEngine.projectile.snapToPoint(at: nearestCell.center) {
                nearestCell.bubbleType = self.gameEngine.projectile.bubbleType

                let gameBubble = GameBubble(as: nearestCell, type: nearestCell.bubbleType, row: nearestCellIndex.section, col: nearestCellIndex.row)

                self.gameEngine.addActiveGameBubble(gameBubble)

                onSnapComplete?(gameBubble)
            }
        } else {
            print("game over")
            showGameOverDialog()
        }
    }

    // Create a dummy rendered image for animations. (fade out/falling animations)
    // These are throw away rendered object to create the illusion. It is remove from view after animation ends.
    internal func createGameBubbleSnapshots(gameBubbles: [GameBubble]) -> [UIView] {
        var result: [UIView] = []
        let snapshots = gameBubbles.map { $0.sprite.snapshotView(afterScreenUpdates: false) }
        let originalPositions = gameBubbles.map { IndexPath(item: $0.col, section: $0.row) }
            .map { self.bubbleGrid.layoutAttributesForItem(at: $0) }

        for (index, snapshot) in snapshots.enumerated() {
            guard let validSnapshot = snapshot else {
                continue
            }

            guard let originalPosition = originalPositions[index] else {
                continue
            }

            validSnapshot.frame = originalPosition.frame
            result.append(validSnapshot)
        }

        return result
    }

    internal func showGameOverDialog() {
        let alert = UIAlertController(title: "Game Over", message: "Retry the level?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes please!", style: .default) { _ in
            self.gameEngine.resetGame()
            self.recoverLevelData()
        })

        alert.addAction(UIAlertAction(title: "No I give up!", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func exitButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
