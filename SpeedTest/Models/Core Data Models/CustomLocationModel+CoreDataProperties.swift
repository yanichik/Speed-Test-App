//
//  CustomLocationModel+CoreDataProperties.swift
//  SpeedTest
//
//  Created by admin on 5/28/24.
//
//

import Foundation
import CoreData


extension CustomLocationModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomLocationModel> {
        return NSFetchRequest<CustomLocationModel>(entityName: "CustomLocationModel")
    }

    @NSManaged public var locationName: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}

extension CustomLocationModel : Identifiable {

}
