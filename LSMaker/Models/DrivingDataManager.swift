//
// Created by Alex Lopez on 15/5/21.
// Copyright (c) 2021 Alex Lopez. All rights reserved.
//

import Foundation

class DrivingDataManager {
    var speed: UInt8
    var turn: UInt8
    var acceleration: UInt8
    var name: String
    var status: Bool

    init() {
        speed = 0x00
        turn = 0x00
        acceleration = 0x00
        name = "Ningún dispositivo"
        status = false
    }

    func setSpeed(velocity: Int) {
        switch velocity {
        case 0:
            speed = 0x00
        case 1..<25:
            speed = 0x25
        case 25..<50:
            speed = 0x50
        case 50..<75:
            speed = 0x75
        case 75...100:
            speed = 0x99
        default:
            speed = 0x00
        }
    }

    func setDirection(direction: String) {
        print("Direction: " + direction)
        switch direction {
        case "straight":
            turn =  0x00
        case "left":
            turn = 0x59
        case "right":
            turn = 0x99
        default:
            turn = 0x00
        }
    }
}
