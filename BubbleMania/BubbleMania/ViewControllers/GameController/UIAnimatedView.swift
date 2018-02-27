//
//  ImageView+Animation.swift
//  BubbleMania
//
//  Created by wongkf on 27/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

class UIAnimatedView: UIImageView {
    
    private(set) var spriteSheet: UIImage?
    private(set) lazy var idleSprite: UIImage? = self.animationImages?.first

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(spriteSheet: UIImage, rowCount: Int, colCount: Int) {
        self.spriteSheet = spriteSheet
        
        super.init(image: spriteSheet)
        
        sliceSpriteSheet(rowCount: rowCount, colCount: colCount)
        
        self.image = idleSprite
        self.sizeToFit()
    }
    
    private func sliceSpriteSheet(rowCount: Int, colCount: Int){
        guard let spriteSheet = self.spriteSheet else {
            return
        }
        
        guard let cgImage = spriteSheet.cgImage else {
            return
        }
        
        let cropWidth = cgImage.width / colCount
        let cropHeight = cgImage.height / rowCount
        
        var sprites: [UIImage] = []
        
        for row in 0..<rowCount {
            for col in 0..<colCount{
                let crop = CGRect(x: cropWidth * col,
                                    y: cropHeight * row,
                                    width: cropWidth,
                                    height: cropHeight)
                guard let cropped = cgImage.cropping(to: crop) else {
                    return
                }
                
                sprites.append(UIImage(cgImage: cropped, scale: spriteSheet.scale, orientation: spriteSheet.imageOrientation))
            }
        }
        
        self.animationImages = sprites
        self.animationDuration = 0.5
        self.animationRepeatCount = 1
    }
    
}
