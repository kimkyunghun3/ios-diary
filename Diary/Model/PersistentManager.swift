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
    associatedtype MapableModel: Mapable

}
extension PersistentManager {

    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func getEntity(id: String) -> NSManagedObject? {
        let request = MapableModel.Entity.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", id)
        request.predicate = predicate
        
        guard let fetchRequest = try? mainContext.fetch(request).first else {
            return nil

        }
        return fetchRequest as? NSManagedObject
    }
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> NSArray {
        let fatchResult = try self.mainContext.fetch(request)
        return fatchResult as NSArray
    }
    
    func register(_ item: MapableModel) throws {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.mainContext)
        if let entity = entity {
            var managedObject = NSManagedObject(entity: entity, insertInto: self.mainContext)
            item.setValue(managedObject: &managedObject)
            
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
        let fatchResult = MapableModel.Entity.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fatchResult)
        try self.mainContext.execute(delete)
    }
    
    func update(_ item: MapableModel) throws {
        guard var entity = getEntity(id: item.uuid) else { return }
        item.setValue(managedObject: &entity)
        
        try self.mainContext.save()
    }
}
