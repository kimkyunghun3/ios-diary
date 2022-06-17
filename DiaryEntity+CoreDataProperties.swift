//
//  DiaryEntity+CoreDataProperties.swift
//  Diary
//
//  Created by 이시원 on 2022/06/17.
//
//

import Foundation
import CoreData


extension DiaryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntity> {
        return NSFetchRequest<DiaryEntity>(entityName: "DiaryEntity")
    }

    @NSManaged public var body: String
    @NSManaged public var createdAt: String
    @NSManaged public var title: String
    @NSManaged public var uuid: String

}

extension DiaryEntity : Identifiable {

}
