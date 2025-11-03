//
//  FakeAPIClient.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp


final class FakeAPIClient: APIClientProtocol {
    enum Mode {
        case success(Data)
        case http(Int)                 // non-2xx
        case network(URLError.Code)    // transport
        case decoding                  // invalid JSON for expected type
    }

    let mode: Mode
    init(mode: Mode) { self.mode = mode }

    func perform<T: Decodable>(_ request: APIRequest) async throws -> T {
        switch mode {
        case .success(let data):
            // decode into requested type
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw APIError.decoding }
        case .http(let code):
            throw APIError.http(code)
        case .network(let code):
            throw APIError.network(code)
        case .decoding:
            throw APIError.decoding
        }
    }
}
