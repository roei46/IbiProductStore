//
//  NetworkService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol HTTPRequest {
    var path: String { get }
    var method: HTTPMethod { get }
}

enum Endpoint: HTTPRequest {
    case products

    
var path: String {
        switch self {
        case .products:
            return "https://dummyjson.com/products"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case invalidData
    case expiredToken
}

protocol FetchData {
    func fetchData<T: Decodable>(from request: HTTPRequest) async throws -> T

}

final class NetworkService: FetchData {
    
    
    private var session: URLSession
    private var decoder: JSONDecoder
    
    
    init(session: URLSession = URLSession(configuration: .default), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetchData<T: Decodable>(from request: HTTPRequest) async throws -> T {
        guard let url = URL(string: request.path) else {
            throw APIError.invalidData
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.expiredToken
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch let decodingError as DecodingError {
            throw APIError.invalidData
        } catch {
            throw APIError.invalidData
        }
    }
}
