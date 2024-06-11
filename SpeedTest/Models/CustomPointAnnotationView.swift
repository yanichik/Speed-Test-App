//
//  CustomPointAnnotationView.swift
//  SpeedTest
//
//  Created by admin on 6/8/24.
//

import UIKit
import MapKit

class CustomPointAnnotationView: MKAnnotationView {
    
//    override var annotation: MKAnnotation? {
//        didSet {
//            guard let annotation = annotation as? MKPointAnnotation else {
////                assertionFailure("Using MKPointAnnotation with wrong annotation type")
//                return
//            }
//            clusteringIdentifier = annotation.title != nil ? annotation.title : nil
//        }
//    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = .clear
//        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let view = self.nibInstantiate(autoResizingMask: [.flexibleHeight, .flexibleWidth])
        frame = view.frame
        addSubview(view)
    }
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