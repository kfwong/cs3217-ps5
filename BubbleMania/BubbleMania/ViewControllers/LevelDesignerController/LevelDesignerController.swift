//
//  ViewController.swift
//  LevelDesigner
//
//  Created by wongkf on 1/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 The main ViewController class has the following resposibilties:
 - Main entry for kicking off UI and gesture initialization.
 - Holding references to UI objects from Storyboard.
 - Define high level functions that manipulate Game Level sate (i.e. save/load a level, select/deselect brush).
 - Define runtime generated "throw away" UI such as alert, toasts, save/load file dialogs.
 - Overriding hook functions from UIViewController lifecycle.
 */
class LevelDesignerController: UIViewController {

    internal var levelData: [Bubble] = []

    internal let oddSectionBubbleCount = 11
    internal let evenSectionBubbleCount = 12
    internal let sectionCount = 13

    internal let oddSectionInset = UIEdgeInsets(top: -8, left: 31, bottom: -8, right: 31)
    internal let evenSectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    internal var brushType = BubbleType.none

    // Cannot be declared private because the extensions need to access these references
    // Added allow private set rules to the swiftlint config
    @IBOutlet weak private(set) var bubbleGrid: UICollectionView!

    @IBOutlet weak private(set) var resetButton: UIBarButtonItem!
    @IBOutlet weak private(set) var startButton: UIBarButtonItem!
    @IBOutlet weak private(set) var saveButton: UIBarButtonItem!
    @IBOutlet weak private(set) var loadButton: UIBarButtonItem!
    @IBOutlet weak private(set) var manageButton: UIBarButtonItem!
    @IBOutlet weak private(set) var exitButton: UIBarButtonItem!

    @IBOutlet weak private(set) var pallete: UICollectionView!
    internal let paletteRenderer: PaletteRenderer = PaletteRenderer()

    private let dataController = DataController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bubbleGrid.delegate = self

        self.paletteRenderer.gestureDelegate = self

        self.pallete.dataSource = paletteRenderer
        self.pallete.delegate = paletteRenderer

        setupPaletteActions()
        setupBubbleGridActions()

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

    // Deselect any brushes when user tap on gray palette area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dehighlightAllBrush()
        brushType = .none
    }

    internal func highlightSelectedBrush(_ brush: UICollectionViewCell) {
        brush.layer.borderWidth = 3
        brush.layer.borderColor = UIColor.white.cgColor
    }

    internal func dehighlightBrush(_ brush: UICollectionViewCell) {
        brush.layer.borderWidth = 0
        brush.layer.borderColor = nil
    }

    internal func dehighlightAllBrush() {
        pallete.visibleCells.forEach { dehighlightBrush($0) }
    }

    // encode level state and save it to a file
    internal func saveLevel(filename: String) throws {
        levelData = levelData.map {
            guard $0.type == .none else {
                return $0
            }

            $0.type = .erase

            return $0
        }

        if let json = try String(data: dataController.encodeLevelData(levelData), encoding: .utf8) {
            print(json)
            try dataController.saveToFile(filename: filename, json: json)
        }
    }

    // load a file and decode it to recover game level state
    internal func loadLevel(filename: String) throws {

        if let json = try dataController.loadFromFile(filename: filename),
            let data = json.data(using: .utf8) {

            let decoded = try dataController.decodeLevelData(data: data)

            reloadBubbleGrid(bubbles: decoded)
        }
    }

    // not in the specs. For management of save files otherwise it'll be too many files but no way to remove them.
    internal func manageLevel(filename: String) throws {
        try dataController.removeFile(filename: filename)
    }

    // Shows a save file dialog that prompt user for filename. Overwrites any existing file with the same name.
    internal func showSaveFileDialog() {
        let alert = UIAlertController(title: "Save Level Data", message: "Enter your file name. \nWARNING: Any existing file with same name will be overriden.", preferredStyle: .alert)

        alert.addTextField { $0.text = "" }

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert] (_) in
            guard let filename = alert?.textFields?[0].text else {
                fatalError("Can't retrieve value from the dialog input field!")
            }

            if (try? self.saveLevel(filename: filename)) != nil {
                self.showToast(message: "Level [\(filename)] saved successfully.")
            } else {
                self.showToast(message: "Level [\(filename)] saved failed. Try again?")
            }

        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    // Show a list of saved files that can be loaded.
    internal func showLoadFileDialog() {
        guard let levelDataFiles = try? dataController.listLevelDataFiles() else {
            showToast(message: "Fail to list data files. Try again?")
            return
        }

        let alert = UIAlertController(title: "Load Level Data", message: "Please choose a level data to load.", preferredStyle: .alert)

        levelDataFiles.forEach {
            let filename = $0

            alert.addAction(UIAlertAction(title: $0, style: .default) { _ in
                if (try? self.loadLevel(filename: filename)) != nil {
                    self.showToast(message: "Level [\(filename)] loaded successfully.")
                } else {
                    self.showToast(message: "Level [\(filename)] loaded failed. Try again?")
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }

    // Show a list of saved files. Tapping prompt for confirmation to remove the file from device.
    internal func showManageFileDialog() {
        guard let levelDataFiles = try? dataController.listLevelDataFiles() else {
            showToast(message: "Fail to list data files. Try again?")
            return
        }

        let alert = UIAlertController(title: "Manage Level Data", message: "Choose a level data to be removed.", preferredStyle: .alert)

        levelDataFiles.forEach {
            let filename = $0

            alert.addAction(UIAlertAction(title: $0, style: .default) { _ in

                self.showConfirmationDialog(title: "Are you sure?",
                                            message: "Removed file cannot be recovered.",
                                            okAction: { _ in
                                                if (try? self.manageLevel(filename: filename)) != nil {
                                                    self.showToast(message: "Level [\(filename)] removed successfully.")
                                                } else {
                                                    self.showToast(message: "Level [\(filename)] removed failed. Try again?")
                                                }
                                            },
                                            cancelAction: nil)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }

    // Show a simple confirmation dialog with ok and cancel button.
    // Caller can define actions to be done for respective button.
    internal func showConfirmationDialog(title: String, message: String, okAction: ((UIAlertAction) -> Void)?, cancelAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okAction))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelAction))

        self.present(alert, animated: true, completion: nil)
    }

    // Show a simple notification toast that fades after a fix duration.
    internal func showToast(message: String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - self.view.frame.size.width / 4,
                                               y: self.view.frame.size.height / 2, width: self.view.frame.size.width / 2, height: 35))

        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {_ in
            toastLabel.removeFromSuperview() // prevent leaking view
        })
    }

}
