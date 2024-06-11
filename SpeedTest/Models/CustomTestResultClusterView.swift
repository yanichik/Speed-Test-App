//
//  CustomTestResultClusterView.swift
//  SpeedTest
//
//  Created by admin on 5/31/24.
//

import Foundation
import MapKit

class CustomTestResultClusterView: MKAnnotationView {
//    private var countLabel = UILabel()
    @IBOutlet private weak var countLabel: UILabel!
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? MKClusterAnnotation else {
//                assertionFailure("Using CustomTestResultClusterView with wrong annotation type")
                return
            }
            clusteringIdentifier = annotation.title
//            countLabel.text = annotation.memberAnnotations.count < 100 ? "\(annotation.memberAnnotations.count)" : "99+"
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height/2)
        setupUI()
        setUI(with: annotation as! MKClusterAnnotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
//        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let view = self.nibInstantiate(autoResizingMask: [.flexibleHeight, .flexibleWidth])
//        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = view.frame
        addSubview(view)
//        self.addSubview(countLabel)
//        countLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            countLabel.topAnchor.constraint(equalTo: self.topAnchor),
//        ])
    }
    
    private func setUI(with clusterAnnotation: MKClusterAnnotation?) {
        if let count = clusterAnnotation?.memberAnnotations.count {
            countLabel.text = count.description
        } else {
            countLabel.text = nil
            countLabel.isHidden = true
        }
    }
}
