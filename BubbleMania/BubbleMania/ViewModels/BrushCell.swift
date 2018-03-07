//
//  BrushCell.swift
//  BubbleMania
//
//  Created by wongkf on 1/3/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
/**
 The BubbleCell is a custom UICollectionViewCell
 that holds the model and states of an individual Bubble in the grid.
 */
class BrushCell: UICollectionViewCell {

    internal var bubbleType = BubbleType.none {
        willSet(brushType) {
            self.layer.cornerRadius = self.frame.width / 2
            self.bubbleImage.image = UIImage(named: brushType.rawValue)

            if brushType == .erase {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
                self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
            }
        }
    }

    @IBOutlet weak private var bubbleImage: UIImageView!

    // the following method must be called at least once to intialize the parameters.
    // overriding init() will not work because it throws runtime exception due to how iOS handles UI render lifecycle
    func render(bubbleType: BubbleType) {
        self.bubbleType = bubbleType
    }

}
