//
//  PaletteRenderer.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

class PaletteRenderer: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    weak var gestureDelegate: PaletteGestureDelegate?

    private let brushSize = CGSize(width: 50, height: 50)
    private let brushPadding = 10

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BubbleType.paletteBubbleTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let brush = collectionView.dequeueReusableCell(withReuseIdentifier: "brushCell", for: indexPath) as? BrushCell else {
            fatalError("Fail to initialize palette brush!")
        }

        brush.render(bubbleType: BubbleType.paletteBubbleTypes[indexPath.item])

        return brush
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let brushCell = collectionView.cellForItem(at: indexPath) as? BrushCell {
            gestureDelegate?.onSelectBrush(brushType: brushCell.bubbleType, brushCell: brushCell)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return brushSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = Int(brushSize.width) * BubbleType.paletteBubbleTypes.count
        let totalSpacingWidth = brushPadding * (BubbleType.paletteBubbleTypes.count - 1)

        let leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        let topInset = (collectionView.bounds.height - brushSize.width) / 2
        let bottomInset = topInset
        return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }

}

protocol PaletteGestureDelegate: class {
    func onSelectBrush(brushType: BubbleType, brushCell: BrushCell)
}
