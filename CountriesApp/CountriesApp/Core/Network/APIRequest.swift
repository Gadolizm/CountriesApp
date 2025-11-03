//
//  APIRequest.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

struct APIRequest {
    let path: String
    var method: HTTPMethod = .GET
    var query: [String: String] = [:]
    var headers: [String: String] = [:]
    var body: Data? = nil

    func urlRequest(base: URL) throws -> URLRequest {
        guard var comps = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        else { throw URLError(.badURL) }

        if !query.isEmpty {
            comps.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = comps.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        if let body { req.httpBody = body }

        // default headers (can be overridden)
        if body != nil && headers["Content-Type"] == nil {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        headers.forEach { req.addValue($0.value, forHTTPHeaderField: $0.key) }
        return req
    }
}

extension APIRequest {
    static func countriesAll(fields: [String]) -> APIRequest {
        .init(
            path: "/v2/all",
            method: .GET,
            query: ["fields": fields.joined(separator: ",")]
        )
    }
}
