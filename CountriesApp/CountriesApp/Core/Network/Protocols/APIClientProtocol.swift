//
//  APIClientProtocol.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


protocol APIClientProtocol {
    func perform<T: Decodable>(_ request: APIRequest) async throws -> T
}
