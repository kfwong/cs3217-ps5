//
//  ImageView+Animation.swift
//  BubbleMania
//
//  Created by wongkf on 27/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

/*
 precondition:
 A subclass of UIImageView that assume the image as spritesheet
 caller need to explicitly states the rows and cols count for spritesheet
 
 postcondition:
 each sprite is of equal width and height after slicing stored in the UIView.animationImages property.
 */
class UIAnimationView: UIImageView {

    private(set) var spriteSheet: UIImage?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(spriteSheet: UIImage, rowCount: Int, colCount: Int, idleSpriteIndex: IndexPath = IndexPath(item: 0, section: 0), animationDuration: TimeInterval = 1.0, animationRepeatCount: Int = 1) {
        self.spriteSheet = spriteSheet

        super.init(image: spriteSheet)

        let sprites = sliceSpriteSheet(rowCount: rowCount, colCount: colCount)

        self.animationImages = sprites
        self.image = sprites[rowCount * idleSpriteIndex.section + idleSpriteIndex.item] // as initial idle image when animation stopped
        self.animationDuration = animationDuration
        self.animationRepeatCount = animationRepeatCount

        self.sizeToFit() // resize automaticallty ro idle image instead of spritesheet dimension
    }

    // slice the spritesheets given row and col count
    private func sliceSpriteSheet(rowCount: Int, colCount: Int) -> [UIImage] {
        guard let spriteSheet = self.spriteSheet else {
            return []
        }

        guard let cgImage = spriteSheet.cgImage else {
            return []
        }

        // divide each sprite's dimension evenly
        let cropWidth = cgImage.width / colCount
        let cropHeight = cgImage.height / rowCount

        var sprites: [UIImage] = []

        for row in 0..<rowCount {
            for col in 0..<colCount {
                let crop = CGRect(x: cropWidth * col,
                                    y: cropHeight * row,
                                    width: cropWidth,
                                    height: cropHeight)
                guard let cropped = cgImage.cropping(to: crop) else {
                    continue
                }

                sprites.append(UIImage(cgImage: cropped, scale: spriteSheet.scale, orientation: spriteSheet.imageOrientation))
            }
        }

        return sprites
    }

}
