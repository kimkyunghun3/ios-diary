//
//  Diary.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/13.
//

import Foundation

struct Diary: Codable, Hashable {
    let title: String?
    let body: String?
    let createdAt: String?
    let uuid: UUID

    private enum CodingKeys: String, CodingKey {
        case title, body
        case createdAt = "created_at"
    }
    
    init(title: String, body: String, createdAt: String, uuid: UUID = UUID()) {
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
        self.uuid = UUID()
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
