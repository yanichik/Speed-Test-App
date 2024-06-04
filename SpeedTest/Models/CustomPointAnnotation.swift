//
//  CustomPointAnnotation.swift
//  SpeedTest
//
//  Created by admin on 6/1/24.
//

import Foundation
import MapKit

class CustomPointAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(latitude: Double, longitude: Double){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
}
