//
//  NetworkManager.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/24.
//

import UIKit

enum NetWorkError: Error {
    case response
    case decode
    case url
}

final class NetworkManager {
    func fetchWeatherData(urlRequest: URLRequest) async throws -> String? {
        return try await Task { () -> String? in
            guard let url = urlRequest.url else {
                throw NetWorkError.url
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...300).contains(httpResponse.statusCode) else {
                      throw NetWorkError.response
                  }
            
            guard let data = try? JSONDecoder().decode(Weather.self, from: data) else {
                throw NetWorkError.decode
            }
            
            return data.icons.first?.icon
        }.value
    }
    
    func fetchImageData(urlRequest: URLRequest) -> Task<UIImage, Error> {
        return Task { () -> UIImage in
            guard let url = urlRequest.url else {
                throw NetWorkError.url
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...300).contains(httpResponse.statusCode) else {
                      throw NetWorkError.response
                  }
            
            guard let image = UIImage(data: data) else {
                throw NetWorkError.decode
            }
            
            return image
        }
    }
}
