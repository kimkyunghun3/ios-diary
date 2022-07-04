//
//  DiaryEntity+CoreDataProperties.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/20.
//
//

import Foundation
import CoreData

extension DiaryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntity> {
        return NSFetchRequest<DiaryEntity>(entityName: "DiaryEntity")
    }

    @NSManaged public var body: String
    @NSManaged public var createdAt: Date
    @NSManaged public var title: String
    @NSManaged public var uuid: UUID
    @NSManaged public var weatherIcon: String

}

extension DiaryEntity: Identifiable {

}
