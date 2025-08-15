//
//  ProductService.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import Foundation

final class PorductService {
    
}
protocol PorductServiceProtocol {
    var apiClient: NetworkService { get set }
    
    func getProduct() async throws -> ProductResponse
    func getProducts(limit: Int, skip: Int) async throws -> ProductResponse
}


final class ProductService: ObservableObject, PorductServiceProtocol {
    var apiClient: NetworkService
    
    init(apiClient: NetworkService = NetworkService()) {
        self.apiClient = apiClient
    }
    
    func getProduct() async throws -> ProductResponse {
        try await apiClient.fetchData(from: Endpoint.products)
    }
    
    func getProducts(limit: Int, skip: Int) async throws -> ProductResponse {
        try await apiClient.fetchData(from: Endpoint.productsWithPagination(limit: limit, skip: skip))
    }
}
