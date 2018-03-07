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
class MenuController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet private(set) weak var dim: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.dim.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dim.addSubview(blurEffectView)

        self.dim.isUserInteractionEnabled = false
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

    @IBAction func playButtonAction(_ sender: UIButton) {
        let tableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "levelSelection")
        tableViewController.modalPresentationStyle = UIModalPresentationStyle.popover

        let popoverPresentationController = tableViewController.popoverPresentationController
        popoverPresentationController?.sourceView = self.view
        popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popoverPresentationController?.delegate = self

        present(tableViewController, animated: true) {
            UIView.animate(withDuration: 0.5) {
                            self.dim.alpha = 1
            }
        }
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        UIView.animate(withDuration: 0.5) {
                        self.dim.alpha = 0
        }
    }
}
