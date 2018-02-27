//
//  ViewController+DataControllerTests.swift
//  LevelDesignerTests
//
//  Created by wongkf on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import XCTest
@testable import LevelDesigner

class ViewController_DataControllerTests: XCTestCase {

    func testEncodeLevelData() throws {
        let dataController = ViewController()
        let bubbles = [Bubble(xIndex: 0, yIndex: 0), Bubble(xIndex: 1, yIndex: 2), Bubble(xIndex: 3, yIndex: 4)]
        let expectedOutput = "[{\"type\":\"bubble-gray\",\"yIndex\":0,\"xIndex\":0},{\"type\":\"bubble-gray\",\"yIndex\":2,\"xIndex\":1},{\"type\":\"bubble-gray\",\"yIndex\":4,\"xIndex\":3}]"

        let encoded = try dataController.encodeLevelData(bubbles)

        let output = String(data: encoded, encoding: .utf8)

        XCTAssertEqual(output, expectedOutput, "Encoded format does not match")
    }

    func testDecodeLevelData() throws {
        let dataController = ViewController()
        let json = "[{\"type\":\"bubble-gray\",\"yIndex\":0,\"xIndex\":0},{\"type\":\"bubble-gray\",\"yIndex\":2,\"xIndex\":1},{\"type\":\"bubble-gray\",\"yIndex\":4,\"xIndex\":3}]"
        let expectedOutput =  [Bubble(xIndex: 0, yIndex: 0), Bubble(xIndex: 1, yIndex: 2), Bubble(xIndex: 3, yIndex: 4)]

        if let data = json.data(using: .utf8) {
            let decoded = try dataController.decodeLevelData(data: data)

            expectedOutput.forEach {
                let expectedBubble = $0
                XCTAssertTrue(decoded.contains {
                    return $0.type == expectedBubble.type &&
                        $0.xIndex == expectedBubble.xIndex &&
                        $0.yIndex == expectedBubble.yIndex
                }, "Fail to decode json")
            }
        } else {
            XCTFail("Decode json went horribly wrong")
        }
    }

    // will fail on simulator with write protected partitions
    func testSaveToFileAndRemoval() throws {
        let dataController = ViewController()
        let testFileName = "testfilename"
        try dataController.saveToFile(filename: testFileName, json: "[{\"type\":\"bubble-gray\",\"yIndex\":0,\"xIndex\":0}]")

        let files = try dataController.listLevelDataFiles()

        XCTAssertTrue(files.contains { $0 == testFileName }, "Fail to save to file")

        try dataController.removeFile(filename: testFileName)
    }

    // will fail on simulator with read protected partitions
    func testLoadFromFileAndRemoval() throws {
        let dataController = ViewController()
        let testFileName = "testfilename"
        let testContent = "[{\"type\":\"bubble-gray\",\"yIndex\":0,\"xIndex\":0}]"
        try dataController.saveToFile(filename: testFileName, json: "[{\"type\":\"bubble-gray\",\"yIndex\":0,\"xIndex\":0}]")

        let json = try dataController.loadFromFile(filename: testFileName)

        XCTAssertEqual(json, testContent, "JSON format does not match")

        try dataController.removeFile(filename: testFileName)
    }
}
