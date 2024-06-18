//
//  CustomTestResultClusterView.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 5/31/24.
//

import Foundation
import MapKit

class CustomTestResultClusterView: MKAnnotationView {
    @IBOutlet private weak var countLabel: UILabel!
    var memberAnnotations: [any MKAnnotation]?
    var coordinate: CLLocationCoordinate2D?
    var title: String?
    
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? MKClusterAnnotation else {
                return
            }
            memberAnnotations = annotation.memberAnnotations
            coordinate = annotation.coordinate
            title = annotation.title
            clusteringIdentifier = annotation.title
            let myView = UILabel()
            myView.backgroundColor = .green
            myView.text = "Click Here"
            myView.adjustsFontSizeToFitWidth = true
            
            let widthConstraint = NSLayoutConstraint(item: myView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
            myView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: myView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
            myView.addConstraint(heightConstraint)
            
            detailCalloutAccessoryView = myView
//            detailCalloutAccessoryView = CustomCalloutView(annotation: annotation.memberAnnotations[0] as! CustomPointAnnotation)
//            leftCalloutAccessoryView = CustomCalloutView(annotation: annotation.memberAnnotations[1] as! CustomPointAnnotation)
//            rightCalloutAccessoryView = CustomCalloutView(annotation: annotation.memberAnnotations[2] as! CustomPointAnnotation)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .required
        collisionMode = .rectangle
        canShowCallout = false
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        centerOffset = CGPoint(x: 0, y: -frame.size.height/2)
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
    
    // Used when mapView cannot zoom in and want to view results of a clustered annotation at max zoom
    public func annotationInAlert() -> UIAlertController? {
        guard let annotation = self.annotation as? MKClusterAnnotation else { return nil }
        let members = annotation.memberAnnotations.map({$0 as! CustomPointAnnotation})
        let alert = UIAlertController(title: "Clustered Results for '\(annotation.title!)'", message: "Showing results for this cluster", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        for member in members {
            alert.addAction(UIAlertAction(title: "\(member.subtitle!)", style: .default))
        }
        return alert
    }
}
