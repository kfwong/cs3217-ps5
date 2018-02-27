//
//  GameObservable.swift
//  GameEngine
//
//  Created by wongkf on 12/2/18.
//  Copyright © 2018 nus.cs3217.a0138862w. All rights reserved.
//

/**
A specialized GameObject that is able to accept observers that get updates when its state changes.
 */

protocol GameObservable {

    func attach <T: GameObserver & Hashable>(observer: T)

    func detach <T: GameObserver & Hashable>(observer: T)

    func notify()
}
