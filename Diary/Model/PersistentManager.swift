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
    var persistentContainer: NSPersistentContainer { get }
    associatedtype Entity: NSManagedObject

}
extension PersistentManager {

    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func getEntity(id: String) -> NSManagedObject? {
        let request = Entity.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", id)
        request.predicate = predicate
        
        guard let fetchRequest = try? mainContext.fetch(request).first else {
            return nil
            
        }
        guard let nsFetchRequest = (fetchRequest as? NSFetchRequest<NSManagedObject>) else {
            return nil
            
        }
        guard let managedObject = try? fetch(request: nsFetchRequest) else {
            return nil
            
        }
        return managedObject.first
    }
    
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
        guard let entity = getEntity(id: item.uuid) else {
            return
            
        }
        self.mainContext.delete(entity)
        
        try self.mainContext.save()
    }
    
    func allDelete() throws {
        let fatchResult = Entity.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fatchResult)
        try self.mainContext.execute(delete)
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
