//
//  MKCoordinateSpan.swift
//  SpeedTest
//
//  Created by admin on 6/17/24.
//

import MapKit

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool
        {
            if lhs.latitudeDelta != rhs.latitudeDelta || lhs.longitudeDelta != rhs.longitudeDelta
            {
                return false
            }
            return true
        }
}
