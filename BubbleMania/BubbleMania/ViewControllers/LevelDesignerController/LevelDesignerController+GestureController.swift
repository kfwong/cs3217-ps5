//
//  ViewController+GestureController.swift
//  LevelDesigner
//
//  Created by wongkf on 7/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 The extension ViewController+GestureController has the following responsibilities:
 - Define binding between UI Objects and their respective actions
 - Define concrete action to be taken when triggered.
 - Define all other gestures such as pan, long press actions.
 */
extension LevelDesignerController: UIGestureRecognizerDelegate {
    internal func setupPaletteActions() {
        blueBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)
        redBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)
        orangeBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)
        greenBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)
        eraseBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)
        noneBubbleBrush.addTarget(self, action: #selector(setupBubbleBrushAction), for: .touchUpInside)

        resetButton.target = self
        resetButton.action = #selector(resetButtonAction)

        startButton.target = self
        startButton.action = #selector(startButtonAction)

        saveButton.target = self
        saveButton.action = #selector(saveButtonAction)

        loadButton.target = self
        loadButton.action = #selector(loadButtonAction)

        manageButton.target = self
        manageButton.action = #selector(manageButtonAction)
    }

    @objc
    private func setupBubbleBrushAction(bubbleBrush: UIButton) {
        switch bubbleBrush {
        case blueBubbleBrush: bubbleBrushTapAction(bubbleBrush, brushType: .blue)
        case redBubbleBrush: bubbleBrushTapAction(bubbleBrush, brushType: .red)
        case orangeBubbleBrush: bubbleBrushTapAction(bubbleBrush, brushType: .orange)
        case greenBubbleBrush: bubbleBrushTapAction(bubbleBrush, brushType: .green)
        case eraseBubbleBrush: bubbleBrushTapAction(bubbleBrush, brushType: .erase)
        case noneBubbleBrush:
            self.brushType = .none
            self.dehighlightAllBrush()
        default: return
        }
    }

    private func bubbleBrushTapAction(_ bubbleBrush: UIButton, brushType: BubbleType) {
        self.brushType = brushType
        self.dehighlightAllBrush()
        self.highlightSelectedBrush(bubbleBrush)
    }

    @objc
    private func startButtonAction(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "GameController", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameController" {
            guard let gameController = segue.destination as? GameController else {
                return
            }

            gameController.passedLevelData = self.levelData.map {
                if $0.type == .erase {
                    $0.type = .none
                }

                return $0
            }
        }
    }

    @objc
    private func saveButtonAction(sender: UIBarButtonItem) {
        showSaveFileDialog()
    }

    @objc
    private func loadButtonAction(sender: UIBarButtonItem) {
        showLoadFileDialog()
    }

    @objc
    private func manageButtonAction(sender: UIBarButtonItem) {
        showManageFileDialog()
    }

    @objc
    private func resetButtonAction(sender: UIButton) {
        reloadBubbleGrid(bubbles: levelData.map {
            $0.type = .erase

            return $0
        })
    }

    internal func setupBubbleGridActions() {
        setupBubbleGridPanAction()
        setupBubbleGridLongPressAction()
    }

    private func setupBubbleGridPanAction() {
        let panGestureRegconizer = UIPanGestureRecognizer(target: self, action: #selector(bubbleGridPanAction))
        panGestureRegconizer.maximumNumberOfTouches = 1
        panGestureRegconizer.minimumNumberOfTouches = 1
        panGestureRegconizer.delegate = self
        self.bubbleGrid.addGestureRecognizer(panGestureRegconizer)
    }

    @objc
    private func bubbleGridPanAction(gesture: UIPanGestureRecognizer) {
        guard brushType != .none else {
            return
        }

        let cellLocation = gesture.location(in: self.bubbleGrid)
        if let cellIndex = self.bubbleGrid.indexPathForItem(at: cellLocation),
            let cell = self.bubbleGrid.cellForItem(at: cellIndex) as? BubbleCell {
            cell.bubbleType = self.brushType
        }
    }

    private func setupBubbleGridLongPressAction() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(bubbleGridLongPressAction))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        bubbleGrid.addGestureRecognizer(longPressGesture)
    }

    @objc
    private func bubbleGridLongPressAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }

        let cellLocation = gesture.location(in: bubbleGrid)
        if let cellIndex = bubbleGrid.indexPathForItem(at: cellLocation),
            let cell = bubbleGrid.cellForItem(at: cellIndex) as? BubbleCell {
            cell.bubbleType = BubbleType.erase
        }

    }
}
