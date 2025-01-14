//
//  UIView+Extension.swift
//  ChildQuestionApp
//
//  Created by alex on 09.02.2023.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
