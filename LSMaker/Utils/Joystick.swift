//
// Created by Alex Lopez on 15/5/21.
// Copyright (c) 2021 Alex Lopez. All rights reserved.
//

import Foundation

class JoystickUtils {
    func getDirectionFromParams(lsMakerJoystick: LSMakerJoystick) -> String {
        if let movement = lsMakerJoystick.angle {
            if isStraight(movement: movement) {
                return "straight"
            } else if isRightTurn(movement: movement) {
                return "right"

            } else if isLeftTurn(movement: movement) {
                return "left"
            }
        }
        return "none"
    }

    func isRightTurn(movement: Int) -> Bool {
        switch movement {
        case 1, 2:
            return true
        default:
            return false
        }
    }

    func isLeftTurn(movement: Int) -> Bool {
        switch movement {
        case 3, 4, 5:
            return true
        default:
            return false
        }
    }

    func isStraight(movement: Int) -> Bool {
        switch movement {
        case 0, 6:
            return true
        default:
            return false
        }

    }
}