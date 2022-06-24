//
//  Diary.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/13.
//

import Foundation
import CoreData

protocol Mapable {
    associatedtype Entity: NSManagedObject
    func setValue(managedObject: inout NSManagedObject)
    var uuid: String { get }
}

struct Diary: Codable, Hashable, Mapable {
    typealias Entity = DiaryEntity
    
    let title: String?
    let body: String?
    let createdAt: String?
    let uuid: String

    private enum CodingKeys: String, CodingKey {
        case title, body
        case createdAt = "created_at"
    }
    
    init(title: String, body: String, createdAt: String, uuid: String = UUID().uuidString) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.uuid = uuid
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        self.body = try values.decode(String.self, forKey: .body)
        self.createdAt = try values.decode(Int.self, forKey: .createdAt).time()
        self.uuid = UUID().uuidString
    }
    
    func setValue(managedObject: inout NSManagedObject) {
        managedObject.setValue(self.title, forKey: "title")
        managedObject.setValue(self.body, forKey: "body")
        managedObject.setValue(self.createdAt, forKey: "createdAt")
        managedObject.setValue(self.uuid, forKey: "uuid")
    }

    static func createData() -> [Diary]? {
        return [Self].parse(name: "sample")
    }
}

private extension Decodable {
    static func parse(name: String) -> Self? {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else { return nil }
        guard let jsonString = try? String(contentsOfFile: path) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }

        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

private extension Int {
    func time() -> String {
        return DateFormatter().changeDateFormat(time: self)
    }
}
