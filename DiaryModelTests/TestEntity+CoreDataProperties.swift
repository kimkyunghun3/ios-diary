//
//  TestEntity+CoreDataProperties.swift
//  Diary
//
//  Created by 이시원 on 2022/06/17.
//
//

import Foundation
import CoreData


extension TestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestEntity> {
        return NSFetchRequest<TestEntity>(entityName: "TestEntity")
    }

    @NSManaged public var body: String
    @NSManaged public var createdAt: String
    @NSManaged public var title: String
    @NSManaged public var uuid: String

}

extension TestEntity : Identifiable {

}
