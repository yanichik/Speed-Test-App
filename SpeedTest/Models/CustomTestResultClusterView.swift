//
//  CustomTestResultClusterView.swift
//  SpeedTest
//
//  Created by admin on 5/31/24.
//

import Foundation
import MapKit

class CustomTestResultClusterView: MKAnnotationView {
    private var countLabel = UILabel()
    
    override var annotation: (any MKAnnotation)? {
        didSet {
            guard let annotation = annotation as? MKClusterAnnotation else {
                assertionFailure("Using CustomTestResultClusterView with wrong annotation type")
                return
            }
            clusteringIdentifier = annotation.title
            countLabel.text = annotation.memberAnnotations.count < 100 ? "\(annotation.memberAnnotations.count)" : "99+"
        }
    }
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
