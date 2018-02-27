//
//  BubbleTests.swift
//  LevelDesignerUITests
//
//  Created by wongkf on 9/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import XCTest
@testable import LevelDesigner

class BubbleTests: XCTestCase {

    func testBubbleInit() {
        let bubble = Bubble(bubbleType: .blue, xIndex: 0, yIndex: 0)

        XCTAssertEqual(bubble.type, .blue, "Bubble type does not match")
        XCTAssertEqual(bubble.xIndex, 0, "Bubble xIndex does not match")
        XCTAssertEqual(bubble.yIndex, 0, "Bubble yIndex does not match")
    }

    func testBubbleInitNegativeIndexes() {
        let bubble = Bubble(bubbleType: .blue, xIndex: -1, yIndex: -1)

        XCTAssertEqual(bubble.type, .blue, "Bubble type does not match")
        XCTAssertEqual(bubble.xIndex, -1, "Bubble xIndex does not match")
        XCTAssertEqual(bubble.yIndex, -1, "Bubble yIndex does not match")
    }

    func testBubbleConvenienceInit() {
        let bubble = Bubble(indexPathInBubbleGrid: IndexPath(item: 0, section: 0))

        XCTAssertEqual(bubble.type, .erase, "Bubble type does not match")
        XCTAssertEqual(bubble.xIndex, 0, "Bubble xIndex does not match")
        XCTAssertEqual(bubble.yIndex, 0, "Bubble yIndex does not match")
    }

    func testBubbleTypeFiniteStateMachine() {
        var bubbleType = BubbleType.blue

        XCTAssertEqual(bubbleType, .blue, "Bubble type does not match")
        bubbleType = bubbleType.next()

        XCTAssertEqual(bubbleType, .red, "Bubble type does not match")
        bubbleType = bubbleType.next()

        XCTAssertEqual(bubbleType, .orange, "Bubble type does not match")
        bubbleType = bubbleType.next()

        XCTAssertEqual(bubbleType, .green, "Bubble type does not match")
        bubbleType = bubbleType.next()

        XCTAssertEqual(bubbleType, .erase, "Bubble type does not match")
        bubbleType = bubbleType.next()

        XCTAssertEqual(bubbleType, .blue, "Bubble type does not match")

    }
}
