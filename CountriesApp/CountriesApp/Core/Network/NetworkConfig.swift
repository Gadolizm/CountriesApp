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
        baseURL: URL,
        session: URLSession = NetworkConfig.defaultSession(),
        decoder: JSONDecoder = .restCountries
    ) {
        self.baseURL = baseURL
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
    static let defaultBaseURL = URL(string: "https://restcountries.com")!
}
