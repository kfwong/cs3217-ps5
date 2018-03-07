//
//  BubbleCell.swift
//  LevelDesigner
//
//  Created by wongkf on 2/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit
/**
 The BubbleCell is a custom UICollectionViewCell
 that holds the model and states of an individual Bubble in the grid.
 */
class BubbleCell: UICollectionViewCell {

    /**
     The variable bubbleType has a Property Observer to achieve one-way binding to the model and imageView it is holding.
     This delegate the responsibility of updating model and image to each individual bubbleCell in the grid.
     
     In short, the ViewController has no control over how the bubble image is being updated.
     In addition, the model binding is encapsulated within willSet() method when the ViewController make changes to this variable
    */
    internal var bubbleType = BubbleType.erase {
        willSet(brushType) {
            self.bubbleImage.image = UIImage(named: brushType.rawValue)
            self.bubbleImage.alpha = 1
            self.bubble?.type = brushType
            self.layer.cornerRadius = self.frame.size.width / 2

            if brushType == .none {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.backgroundColor = UIColor.clear.cgColor
            } else {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
                self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
            }

        }
    }

    private(set) var bubble: Bubble?

    @IBOutlet private(set) weak internal var bubbleImage: UIImageView!

    // the following method must be called at least once to intialize the parameters.
    // overriding init() will not work because it throws runtime exception due to how iOS handles UI render lifecycle
    func render(bubble: Bubble) {
        self.bubbleImage.image = UIImage(named: BubbleType.erase.rawValue)
        self.bubble = bubble
    }

}
