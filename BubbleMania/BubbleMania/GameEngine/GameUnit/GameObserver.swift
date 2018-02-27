//
//  GameObserver.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

/**
All GameObserver must conform to this protocol so the GameObservable can push changes to it.
 */

protocol GameObserver {
    func receiveUpdate(changesOf observable: GameObservable)
}
