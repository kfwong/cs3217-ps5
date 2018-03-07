//
//  ViewController+BubbleGridRenderer.swift
//  LevelDesigner
//
//  Created by wongkf on 7/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 The extension ViewController+BubbleGridRenderer has the following responsibilities:
 - Define how the UICollectionView (BubbleGrid) layout and render its cells.
 - Define other custom mutating functions for UICollectionView after initial system render.
 */
extension GameController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return section % 2 == 0 ? evenSectionInset : oddSectionInset
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section % 2 == 0 ? evenSectionBubbleCount : oddSectionBubbleCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let bubbleCell = bubbleGrid.dequeueReusableCell(withReuseIdentifier: "bubbleCell", for: indexPath) as? BubbleCell else {
            fatalError("Fail to initialize BubbleCell!")
        }
        let bubble = Bubble(xIndex: indexPath.section, yIndex: indexPath.item)

        bubbleCell.render(bubble: bubble)
        bubbleCell.bubbleType = .none

        // the levelData array maintain strong references to all bubble models
        // use for saving the game level state
        self.levelData.append(bubble)

        return bubbleCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / CGFloat(self.evenSectionBubbleCount)

        return CGSize(width: cellWidth, height: cellWidth)
    }

    // update bubble grid state given an array of Bubble objects
    internal func reloadBubbleGrid(bubbles: [Bubble]) {
        bubbles.forEach {
            let cellIndex = IndexPath(item: $0.yIndex, section: $0.xIndex)

            if let bubbleCell = self.bubbleGrid.cellForItem(at: cellIndex) as? BubbleCell {
                bubbleCell.bubbleType = $0.type
            }
        }
    }
}
