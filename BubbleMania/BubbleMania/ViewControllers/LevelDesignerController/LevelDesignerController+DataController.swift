//
//  ViewController+DataController.swift
//  LevelDesigner
//
//  Created by wongkf on 7/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import UIKit

/**
 The extension ViewController+DataController has the following responsibilities:
 - Define the format to encode/decode Game Level state into files.
 - Define how to save/load/delete file on devices.
 */
extension LevelDesignerController {

    // encode bubble object in memory as data
    internal func encodeLevelData(_ bubbles: [Bubble]) throws -> Data {
        return try JSONEncoder().encode(bubbles)
    }

    // decode data as bubble object in memory
    internal func decodeLevelData(data: Data) throws -> [Bubble] {
        return try JSONDecoder().decode([Bubble].self, from: data)
    }

    // save a json string to a file
    internal func saveToFile(filename: String, json: String) throws {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        let documentDirectory = urls[0]
        let fileURL = documentDirectory.appendingPathComponent(filename)

        try json.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
    }

    // load a saved file and return the json string
    internal func loadFromFile(filename: String) throws -> String? {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        let documentDirectory = urls[0]
        let fileURL = documentDirectory.appendingPathComponent(filename)

        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    // remove a file given filename
    internal func removeFile(filename: String) throws {

        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        let documentDirectory = urls[0]
        let fileURL = documentDirectory.appendingPathComponent(filename)

        try FileManager.default.removeItem(at: fileURL)
    }

    // list all saved data files in app document directory[0]
    internal func listLevelDataFiles() throws -> [String] {

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0]

        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])

        return directoryContents.map { $0.lastPathComponent }

    }
}
