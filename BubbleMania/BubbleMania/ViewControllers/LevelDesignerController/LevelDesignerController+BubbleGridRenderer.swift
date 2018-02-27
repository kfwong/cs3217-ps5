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
extension LevelDesignerController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

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
        bubbleCell.backgroundView = UIImageView(image: UIImage(named: BubbleType.erase.rawValue))

        bubbleCell.render(bubble: bubble)

        // the levelData array maintain strong references to all bubble models
        // use for saving the game level state
        self.levelData.append(bubble)

        return bubbleCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let bubbleCell = self.bubbleGrid.cellForItem(at: indexPath) as? BubbleCell {
            // Each BubbleType inside the cell holds the current state (bubble color).
            // calling next() will transition to another state (See Bubble.swift).
            let nextBrushType = bubbleCell.bubbleType.next()

            // cycling the bubble state only if no brush is currently selected
            if self.brushType == .none {
                bubbleCell.bubbleType = nextBrushType
            } else {
                bubbleCell.bubbleType = self.brushType
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCell: CGFloat = 12
        let cellWidth = collectionView.frame.size.width / numberOfCell

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
