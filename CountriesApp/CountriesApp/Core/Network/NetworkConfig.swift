//
//  NetworkConfig.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation


struct NetworkConfig {
    let baseURL: URL
    let session: URLSession
    let decoder: JSONDecoder

    init(
        baseURL: URL? = nil,
        session: URLSession = NetworkConfig.defaultSession(),
        decoder: JSONDecoder = .restCountries
    ) throws {
        self.baseURL = try baseURL ?? NetworkConfig.makeDefaultBaseURL()
        self.session = session
        self.decoder = decoder
    }

    static func defaultSession() -> URLSession {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 15
        c.timeoutIntervalForResource = 30
        c.requestCachePolicy = .useProtocolCachePolicy
        c.urlCache = .shared
        return URLSession(configuration: c)
    }
}

extension JSONDecoder {
    static let restCountries: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()
}

extension NetworkConfig {
    static func makeDefaultBaseURL() throws -> URL {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = "restcountries.com"
        guard let url = comps.url else { throw URLError(.badURL) }
        return url
    }
}
