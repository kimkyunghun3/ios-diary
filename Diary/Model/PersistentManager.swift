//
//  PersistentManager.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/17.
//

import Foundation
import CoreData

protocol PersistentManager {
    var entityName: String { get }
    associatedtype Entity: NSManagedObject
    
//    init(entityName: String) {
//        self.entityName = entityName
//    }
    
}
extension PersistentManager {
    private var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load \(error)")
            }
        }
        
        return container
    }
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func getEntity(id: UUID) -> NSManagedObject? {
        let request = Entity.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.predicate = predicate
        guard let fetchRequest = try? mainContext.fetch(request).first else { return nil }
        guard let nsFetchRequest = (fetchRequest as? NSFetchRequest<NSManagedObject>) else { return nil }
        //return try? mainContext.fetch(request)
        guard let managedObject = try? fetch(request: nsFetchRequest) else { return nil }
        return managedObject.first
    }
    
//    func fetch() throws -> [Diary] {
//        let request = DiaryEntity.fetchRequest()
//
//        return try self.mainContext.fetch(request).map {
//            Diary(title: $0.title, body: $0.body, createdAt: $0.createdAt, uuid: $0.uuid)
//        }
//    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T] {
        let fatchResult = try self.mainContext.fetch(request)
        return fatchResult
    }
    
    func register(_ item: Diary) throws {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainContext)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.mainContext)
            managedObject.setValue(item.title, forKey: "title")
            managedObject.setValue(item.body, forKey: "body")
            managedObject.setValue(item.createdAt, forKey: "createdAt")
            managedObject.setValue(item.uuid, forKey: "uuid")
            
            try self.mainContext.save()
        }
    }
    
    func delete(_ item: Diary) throws {
        guard let entity = getEntity(id: item.uuid) else { return }
        self.mainContext.delete(entity)
        
        try self.mainContext.save()
    }
    
    func update(_ item: Diary) throws {
        let entity = getEntity(id: item.uuid)
        entity?.setValue(item.title, forKey: "title")
        entity?.setValue(item.body, forKey: "body")
        entity?.setValue(item.createdAt, forKey: "createdAt")
        entity?.setValue(item.uuid, forKey: "uuid")
        
        try self.mainContext.save()
    }
}
