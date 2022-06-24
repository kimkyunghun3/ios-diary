//
//  APIable.swift
//  Diary
//
//  Created by 이시원 on 2022/06/24.
//

import Foundation

protocol APIable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get }
}

extension APIable {
    func makeURLRequest() -> URLRequest? {
        guard let url = makeURL() else { return nil }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }
    
    private func makeURL() -> URL? {
        var urlComponents = URLComponents(string: baseURL + path)
        
        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { key, value in
                return URLQueryItem(name: key, value: value)
            }
        }
        return urlComponents?.url
    }
}

struct WeatherAPI: APIable {
    let baseURL: String = "https://api.openweathermap.org/data/2.5/weather"
    let path: String = ""
    let method: HTTPMethod = .get
    let parameters: [String: String]?
}

struct IconAPI: APIable {
    let baseURL: String = "http://openweathermap.org/img/wn/"
    let path: String
    let method: HTTPMethod = .get
    let parameters: [String: String]? = nil
}
