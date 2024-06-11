//
//  CircleImageView.swift
//  Map-UIKit
//
//  Created by Cagri Gider on 22.08.2023.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {

    @IBInspectable
    var circle: Bool {
        set {
            self.isCircle = newValue
            self.setCircle()
        }
        get { self.isCircle }
    }
    
    private var isCircle: Bool = false

    private func setCircle() {
        if isCircle {
            layer.cornerRadius = bounds.size.width / 2
        }
    }
}
