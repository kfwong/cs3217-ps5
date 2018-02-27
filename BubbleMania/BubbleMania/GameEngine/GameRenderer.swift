//
//  GameEngine.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

import Foundation
import UIKit

/**
 Basic GameRenderer that draw objects on screen.
 */
class GameRenderer {

    private var display: CADisplayLink?
    private var gameEngine: GameEngine?

    internal func start(engine: GameEngine) {
        // To remove any previous link if there's any
        stop()

        self.gameEngine = engine

        // add main thread (UI) to synchronize with device's refresh rate
        self.display = CADisplayLink(target: self, selector: #selector(gameLoopStarted))
        self.display?.add(to: .main, forMode: .defaultRunLoopMode)
    }

    internal func stop() {
        self.display?.invalidate()
        self.display = nil
    }

    @objc
    private func gameLoopStarted() {
        gameEngine?.updateGameLoop()
    }
}
