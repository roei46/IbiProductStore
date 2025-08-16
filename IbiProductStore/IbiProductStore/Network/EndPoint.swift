//
//  EndPoint.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 16/08/2025.
//

import Foundation

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
    case productsWithPagination(limit: Int, skip: Int)

    
var path: String {
        switch self {
        case .products:
            return "https://dummyjson.com/products"
        case .productsWithPagination(let limit, let skip):
            return "https://dummyjson.com/products?limit=\(limit)&skip=\(skip)"
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
