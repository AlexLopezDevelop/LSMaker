//
//  CustomButton.swift
//  LSMaker
//
//  Created by Alex Lopez on 15/09/2020.
//  Copyright © 2020 Alex Lopez. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Button onClick animation
    func touchIn() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = .init(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func touchEnd() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchIn()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEnd()
    }
}
