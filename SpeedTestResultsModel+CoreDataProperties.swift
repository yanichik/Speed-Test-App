//
//  SpeedTestResultsModel+CoreDataProperties.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 5/31/24.
//
//

import Foundation
import CoreData


extension SpeedTestResultsModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpeedTestResultsModel> {
        return NSFetchRequest<SpeedTestResultsModel>(entityName: "SpeedTestResultsModel")
    }

    @NSManaged public var county: String?
    @NSManaged public var date: Date?
    @NSManaged public var downloadSpeedMbps: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var savedLocationName: String?
    @NSManaged public var uploadSpeedMbps: Double

}

extension SpeedTestResultsModel : Identifiable {

}
