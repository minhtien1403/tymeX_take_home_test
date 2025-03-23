//
//  UIView+Shadow.swift
//  TymeX
//
//  Created by Trần Tiến on 21/3/25.
//

import UIKit

extension UIView {
    
    func applyShadow(radius: CGFloat = 5,
                     opacity: Float = 0.3,
                     offset: CGSize = CGSize(width: -5, height: 5),
                     color: UIColor = UIColor.black) {
        let layer = self.layer
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        layer.masksToBounds = false
    }
}

