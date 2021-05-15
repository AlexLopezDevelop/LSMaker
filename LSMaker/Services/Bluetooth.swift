//
// Created by Alex Lopez on 14/5/21.
// Copyright (c) 2021 Alex Lopez. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothService {
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?

    func initialize(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.characteristic = characteristic
    }

    func move(speed: UInt8, acceleration: UInt8, turn: UInt8) {
        let value: [UInt8] = [
            0x00, // header
            0x00, // opcode
            speed, // speed
            acceleration, // acceleration
            turn // turn
        ]

        if let lsmakerCharacteristic = characteristic {
            peripheral?.writeValue(Data(value), for: lsmakerCharacteristic, type: .withoutResponse)
        }
    }

}