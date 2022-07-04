//
//  Diary.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/13.
//

import Foundation

struct Diary: Hashable {
    let title: String?
    let body: String?
    let createdAt: Date
    let weatherIcon: String
    let uuid: UUID
    
    init(title: String, body: String, createdAt: Date, weatherIcon: String, uuid: UUID = UUID()) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.weatherIcon = weatherIcon
        self.uuid = uuid
    }
}
