//
//  LevelDesignerUITests.swift
//  LevelDesignerUITests
//
//  Created by wongkf on 1/2/18.
//  Copyright © 2018 nus.cs3217.a0101010. All rights reserved.
//

import XCTest

class LevelDesignerUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTapToPaintCell() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        XCUIApplication().buttons["blueBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap()

        XCUIApplication().buttons["redBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 1).tap()

        XCUIApplication().buttons["orangeBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 2).tap()

        XCUIApplication().buttons["greenBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 3).tap()
    }

    func testTapToEraseCell() {
        XCUIApplication().buttons["blueBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap()

        XCUIApplication().buttons["eraseBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap()
    }

    func testTapToCycleBetweenBubblePalette() {
        XCUIApplication().buttons["noneBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // blue
        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // red
        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // orange
        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // green
        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // erase
        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap() // blue
    }

    // need to do these actions together so the test file is init and properly removed
    func testSaveResetLoadRemoveLevel() {
        XCUIApplication().buttons["blueBubbleBrush"].tap()

        XCUIApplication().collectionViews.cells.element(boundBy: 0).tap()

        XCUIApplication().buttons["SAVE"].tap()

        XCUIApplication().alerts["Save Level Data"].textFields.firstMatch.typeText("UITestFile")

        XCUIApplication().buttons["OK"].tap()

        XCUIApplication().buttons["RESET"].tap()

        XCUIApplication().buttons["LOAD"].tap()

        XCUIApplication().alerts["Load Level Data"].buttons["UITestFile"].tap()

        XCUIApplication().buttons["MANAGE"].tap()

        XCUIApplication().alerts["Manage Level Data"].buttons["UITestFile"].tap()

        XCUIApplication().alerts["Are you sure?"].buttons["OK"].tap()
    }

}
