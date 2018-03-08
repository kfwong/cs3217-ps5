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

    private let GAME_OVER = "Game Over"
    private let RETRY_LEVEL = "Retry the level?"
    private let YES = "Yes please!"
    private let NO = "No I give up!"
    private let GAME_CLEAR = "Game Cleared"
    private let QUIT = "Quit"
    private let CONGRATS = "Congratulation!"

    internal var passedLevelData: [Bubble]?

    internal var levelData: [Bubble] = []

    internal let oddSectionBubbleCount = 11
    internal let evenSectionBubbleCount = 12
    internal let sectionCount = 13

    internal let oddSectionInset = UIEdgeInsets(top: -8, left: 31, bottom: -8, right: 31)
    internal let evenSectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    lazy internal var gameEngine = GameEngine(sectionCount: sectionCount, oddSectionBubbleCount: oddSectionBubbleCount)
    private let gameRenderer = GameRenderer()

    private let projectileYOffset: CGFloat = 50

    // http://blog.scottlogic.com/2014/11/20/swift-initialisation.html
    // note that we cannot override the init function. (view is not loaded, will crash if access UI variables that is not yet inited)
    // we have to wait for viewDidLoad() so we can calculate the actual size.
    // preferred choice is to use implicit unwrap here (not allowed in cs3217 :/)
    // fallback to lazy initialization until the bubbleDiameter/bubbleSize is first accessed.
    // crash is impossible because loadProjectile() is always triggered after view is loaded. (whitebox)
    lazy private var bubbleDiameter = (self.bubbleGrid.frame.size.width / CGFloat(max(oddSectionBubbleCount, evenSectionBubbleCount)))
    lazy private(set) var bubbleSize: CGSize = CGSize(width: self.bubbleDiameter, height: self.bubbleDiameter)

    @IBOutlet private(set) weak var canonBase: UIImageView!
    internal var cannon = UIAnimationView(spriteSheet: #imageLiteral(resourceName: "cannon"), rowCount: 2, colCount: 6, animationDuration: 0.4)

    @IBOutlet private(set) weak var upcomingBubble: UIImageView!
    @IBOutlet private(set) weak var bubbleGrid: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bubbleGrid.isUserInteractionEnabled = false

        self.bubbleGrid.delegate = self

        self.gameEngine.delegate = self

        setupCannonView()

        self.view.bringSubview(toFront: cannon)
        self.view.bringSubview(toFront: canonBase)
    }

    override func viewDidAppear(_ animated: Bool) {
        // need to hook on viewDidAppear because there is racing condition when reloading passed variables into the grid
        // therefore it's safer to start the renderer after the view is fully loaded. (segue and transition complete)
        self.gameRenderer.start(engine: gameEngine)
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

    internal func setupCannonView() {
        cannon.adjustAnchorPoint(xPercentage: 0.5, yPercentage: 0.81)

        let yOffset: CGFloat = 5
        cannon.center.x = canonBase.frame.midX
        cannon.center.y = canonBase.frame.midY - canonBase.frame.height / 4 + yOffset

        self.view.addSubview(cannon)
    }

    internal func loadUpcomingBubble() {
        guard let upcomingBubbleType = gameEngine.upcomingBubbles.peek() else {
            return
        }

        self.upcomingBubble.image = UIImage(named: upcomingBubbleType.rawValue)
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

    internal func rotateCannon(deltaRadian angle: CGFloat, onAnimateComplete: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: { self.cannon.transform = CGAffineTransform(rotationAngle: angle) },
                       completion: { _ in onAnimateComplete?() })
    }

    internal func animateCannonBurst() {
        self.cannon.startAnimating()
    }

    internal func animateSnapProjectileToNearestCell(onSnapComplete: ((_ gameBubble: GameBubble) -> Void)? = nil) {
        let landingPoint = CGPoint(x: gameEngine.projectile.xPos, y: self.gameEngine.projectile.yPos)

        if let nearestCellIndex = bubbleGrid.indexPathForItem(at: landingPoint),
            let nearestCell = bubbleGrid.cellForItem(at: nearestCellIndex) as? BubbleCell {

            snapToPoint(target: gameEngine.projectile, at: nearestCell.center) {

                nearestCell.bubbleType = self.gameEngine.projectile.bubbleType

                let gameBubble = GameBubble(as: nearestCell, type: nearestCell.bubbleType, row: nearestCellIndex.section, col: nearestCellIndex.row)

                self.gameEngine.addActiveGameBubble(gameBubble)

                onSnapComplete?(gameBubble)
            }
        } else {
            showGameOverDialog()
        }
    }

    // snapping to point with animation.
    internal func snapToPoint(target: GameProjectile, at: CGPoint, onAnimateComplete: (() -> Void)? = nil) {
        let deltaX = at.x - target.xPos
        let deltaY = at.y - target.yPos

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        target.sprite.transform = CGAffineTransform(translationX: deltaX, y: deltaY)
        }, completion: { _ in
            onAnimateComplete?()
            target.sprite.transform = CGAffineTransform.identity
        })
    }

    // the projectile also can define how the detach animations are. can be converted into one of the projectile strategy object.
    internal func executeDetachEffect(sprites: [UIView], onAnimateComplete: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        sprites.forEach {
                            $0.alpha = 0
                            $0.transform = CGAffineTransform(translationX: 0, y: 300)
                        }
        }, completion: { _ in
            onAnimateComplete?()
        })
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
        let alert = UIAlertController(title: GAME_OVER, message: RETRY_LEVEL, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: YES, style: .default) { _ in
            self.gameEngine.resetGame()
            self.recoverLevelData()
        })

        alert.addAction(UIAlertAction(title: NO, style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })

        self.present(alert, animated: true, completion: nil)
    }

    internal func showGameClearedDialog( action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: GAME_CLEAR, message: CONGRATS, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: QUIT, style: .default) { _ in
            action?()
        })

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func exitButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    internal func isRestrictedAngle(bearing: CGPoint) -> Bool {
        return bearing.y > gameEngine.projectile.center.y - projectileYOffset
    }

}

extension UIView {

    // this technique will preserve the frame before adjusting anchor point (which will changes the frame)
    // and then restore it later
    // as a result, anchor point will be repositioned within its own frame instead of from root point of view
    // ref: https://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view/1968425#1968425
    public func adjustAnchorPoint(xPercentage x: CGFloat, yPercentage y: CGFloat) {
        let oldFrame = self.frame
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.81)
        self.frame = oldFrame
    }
}
