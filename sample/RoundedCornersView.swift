//
//  RoundedCornersView.swift
//  sample
//
//  Created by macbook on 6/22/16.
//  Copyright © 2016 macbook. All rights reserved.
//

import UIKit

@IBDesignable

class RoundedCornersView: UIView {
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

}
