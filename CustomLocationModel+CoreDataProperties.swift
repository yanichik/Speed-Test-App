//
//  CustomLocationModel+CoreDataProperties.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 5/31/24.
//
//

import Foundation
import CoreData


extension CustomLocationModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomLocationModel> {
        return NSFetchRequest<CustomLocationModel>(entityName: "CustomLocationModel")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: Double

}

extension CustomLocationModel : Identifiable {

}
