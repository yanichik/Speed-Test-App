//
//  CustomPointAnnotationView.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 6/8/24.
//

import UIKit
import MapKit

class CustomPointAnnotationView: MKAnnotationView {
    
    private var calloutView: CustomCalloutView?
    
    // Override the annotation property to add custom behavior
        override var annotation: MKAnnotation? {
            willSet {
                // Remove the previous custom callout view if it exists
                calloutView?.removeFromSuperview()
                calloutView = nil

                // newValue is the new MKAnnotation that will be assigned to the annotation property
                guard let customAnnotation = newValue as? CustomPointAnnotation else { return }

                canShowCallout = false // Disable the default callout

                // Create the new custom callout view with the new annotation
                let callout = CustomCalloutView(annotation: customAnnotation)
                callout.translatesAutoresizingMaskIntoConstraints = false
                addSubview(callout)

                // Set constraints for the custom callout view
                NSLayoutConstraint.activate([
                    callout.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    callout.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -5) // Adjust the vertical offset as needed
                ])

                // Assign the new callout view to the property
                calloutView = callout
                calloutView?.isHidden = true
            }
        }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .required
        collisionMode = .rectangle
        commonInit()
    }
    
    deinit {
        print(annotation?.superclass)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        calloutView?.isHidden = !selected
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
