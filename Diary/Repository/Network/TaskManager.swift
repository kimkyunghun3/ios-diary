//
//  TaskManager.swift
//  Diary
//
//  Created by 이시원 on 2022/06/30.
//

import UIKit

final class TaskManager {
    private var task: Task<UIImage, Error>?

    func request(icon: String) async -> UIImage? {
        guard let urlRequest = IconAPI(path: icon + ".png").makeURLRequest() else { return nil }
        self.task = NetworkManager().fetchImageData(urlRequest: urlRequest)
        
        return try? await task?.value
    }
    
    func cancel() {
        task?.cancel()
    }
    
}
