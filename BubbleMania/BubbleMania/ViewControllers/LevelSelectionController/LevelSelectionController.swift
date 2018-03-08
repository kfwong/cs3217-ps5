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
class LevelSelectionController: UITableViewController {

    private let dataController = DataController()
    lazy private var files = (try? dataController.listLevelDataFiles())
    private var levelData: [Bubble]?

    private let segueId = "LevelSelectionController"

    private let sampleLevel1 = "sample-level-1"
    private let sampleLevel2 = "sample-level-2"
    private let sampleLevel3 = "sample-level-3"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fileCell")

        // these level will always be regenerated even if the user deleted them
        // any levels user saved with the same name will be overwritten as well
        try? dataController.saveToFile(filename: sampleLevel1, json: self.initDefaultLevel(name: sampleLevel1))
        try? dataController.saveToFile(filename: sampleLevel2, json: self.initDefaultLevel(name: sampleLevel2))
        try? dataController.saveToFile(filename: sampleLevel3, json: self.initDefaultLevel(name: sampleLevel3))
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

    internal func loadLevel(filename: String) throws {

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)

        cell.textLabel?.text = files?[indexPath.item]
        cell.textLabel?.font = UIFont(name: "Chalkduster", size: 20)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clear

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableCell = tableView.cellForRow(at: indexPath),
            let selectedLabel = tableCell.textLabel,
            let selectedFile = selectedLabel.text,
            let json = try? dataController.loadFromFile(filename: selectedFile),
            let data = json?.data(using: .utf8) {

            self.levelData = try? dataController.decodeLevelData(data: data)

            self.performSegue(withIdentifier: segueId, sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }

        switch segueId {
        case segueId:
            guard let gameController = segue.destination as? GameController else {
                return
            }

            guard let levelData = self.levelData else {
                return
            }

            gameController.passedLevelData = levelData.map {
                if $0.type == .erase {
                    $0.type = .none
                }

                return $0
            }

        default: return
        }

    }

    func initDefaultLevel(name: String) -> String {
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                let contents = try String(contentsOfFile: path)
                return contents
            } catch {
                // contents could not be loaded
            }
        }
        return ""
    }
}
