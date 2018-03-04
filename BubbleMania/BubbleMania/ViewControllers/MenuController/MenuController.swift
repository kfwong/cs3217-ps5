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
class MenuController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
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

}
