//
//  Entity.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/24.
//

import Foundation

struct Weather: Codable {
    let icons: [Icon]
    
    enum CodingKeys: String, CodingKey {
        case icons = "weather"
    }
}

struct Icon: Codable {
    let icon: String?
}
