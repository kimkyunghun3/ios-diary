//
//  NetworkManager.swift
//  Diary
//
//  Created by 이시원 on 2022/06/24.
//

import Foundation
import UIKit

enum NetWorkError: Error {
    case response
    case decode
}

final class NetworkManager {
    func fetchWeatherData(urlRequest: URLRequest) async throws -> Weather? {
        guard let url = urlRequest.url else {
            return nil
            
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...300).contains(httpResponse.statusCode) else {
                  throw NetWorkError.response
              }
        
        guard let data = try? JSONDecoder().decode(Weather.self, from: data) else {
            throw NetWorkError.decode
        }
        
        return data
    }
    
    func fetchImageData(urlRequest: URLRequest) async throws -> UIImage? {
        guard let url = urlRequest.url else {
            return nil
            
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
