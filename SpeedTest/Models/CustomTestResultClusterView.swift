//
//  CustomTestResultClusterView.swift
//  SpeedTest
//
//  Created by admin on 5/31/24.
//

import Foundation
import MapKit

class CustomTestResultClusterView: MKAnnotationView {
    @IBOutlet private weak var countLabel: UILabel!
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? MKClusterAnnotation else {
                return
            }
            clusteringIdentifier = annotation.title
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height/2)
        setupUI()
        setUI(with: annotation as? MKClusterAnnotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let view = self.nibInstantiate(autoResizingMask: [.flexibleHeight, .flexibleWidth])
        self.frame = view.frame
        addSubview(view)
    }
    
    private func setUI(with clusterAnnotation: MKClusterAnnotation?) {
        if let count = clusterAnnotation?.memberAnnotations.count {
            countLabel.text = count < 5 ? "\(count.description)" : "5+"
        } else {
            countLabel.text = nil
            countLabel.isHidden = true
        }
    }
}
