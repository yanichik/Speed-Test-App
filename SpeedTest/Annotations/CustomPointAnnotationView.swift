//
//  CustomPointAnnotationView.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 6/8/24.
//

import UIKit
import MapKit

class CustomPointAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .rectangle
        canShowCallout = true
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .clear
        let view = self.nibInstantiate(autoResizingMask: [.flexibleHeight, .flexibleWidth, .flexibleBottomMargin, .flexibleTopMargin])
        frame = view.frame
        addSubview(view)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: true)
//        print(selected)
//    }
}

extension UIView {
    func nibInstantiate(autoResizingMask: UIView.AutoresizingMask = []) -> UIView {
        let bundle = Bundle(for: Self.self)
        let nib = bundle.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        let view = nib?.first as! UIView
        view.autoresizingMask = autoResizingMask
        return view
    }
}
