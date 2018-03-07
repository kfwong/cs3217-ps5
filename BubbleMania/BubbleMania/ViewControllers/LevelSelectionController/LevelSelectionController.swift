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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fileCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        try? dataController.saveToFile(filename: "level1", json: self.initDefault())
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tableCell = tableView.cellForRow(at: indexPath),
            let selectedLabel = tableCell.textLabel,
            let selectedFile = selectedLabel.text {
            
            let json = try? dataController.loadFromFile(filename: selectedFile)!
            
            
            self.levelData = try? dataController.decodeLevelData(data: json!.data(using: .utf8)!)
            
            
            self.performSegue(withIdentifier: "LevelSelectionController", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LevelSelectionController" {
            guard let gameController = segue.destination as? GameController else {
                return
            }
            
            gameController.passedLevelData = self.levelData!.map {
                if $0.type == .erase {
                    $0.type = .none
                }
                
                return $0
            }
        }
    }
    
    func initDefault() -> String {
        if let path = Bundle.main.path(forResource: "level1", ofType: "json") {
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

