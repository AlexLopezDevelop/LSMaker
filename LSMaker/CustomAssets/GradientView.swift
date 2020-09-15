//
//  GradientView.swift
//  LSMaker
//
//  Created by Alex Lopez on 15/09/2020.
//  Copyright © 2020 Alex Lopez. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    var bottomColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    
    var startPointX: CGFloat = 0
    var startPointY: CGFloat = 0
    var endPointX: CGFloat = 1
    var endPointY: CGFloat = 1
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
