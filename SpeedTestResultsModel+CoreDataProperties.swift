//
//  SpeedTestResultsModel+CoreDataProperties.swift
//  SpeedTest
//
//  Created by admin on 5/21/24.
//
//

import Foundation
import CoreData


extension SpeedTestResultsModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpeedTestResultsModel> {
        return NSFetchRequest<SpeedTestResultsModel>(entityName: "SpeedTestResultsModel")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var downloadSpeedMbps: Double
    @NSManaged public var uploadSpeedMbps: Double
    @NSManaged public var date: Date?

}

extension SpeedTestResultsModel : Identifiable {

}
