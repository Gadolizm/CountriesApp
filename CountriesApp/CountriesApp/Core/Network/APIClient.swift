//
//  APIClientType.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation


final class APIClient: APIClientProtocol {
    private let config: NetworkConfig
    private let backoff = ExponentialBackoff()

    init(config: NetworkConfig) { self.config = config }

    private func isTransient(_ err: URLError) -> Bool {
        switch err.code {
        case .timedOut, .cannotFindHost, .cannotConnectToHost,
             .dnsLookupFailed, .networkConnectionLost, .notConnectedToInternet:
            return true
        default: return false
        }
    }

    func perform<T: Decodable>(_ request: APIRequest) async throws -> T {
        var attempt = 0

        while true {
            do {
                let urlReq = try request.urlRequest(base: config.baseURL)
                let (data, resp) = try await config.session.data(for: urlReq)

                guard let http = resp as? HTTPURLResponse else {
                    throw APIError.network(.badServerResponse)
                }
                guard (200...299).contains(http.statusCode) else {
                    throw APIError.http(http.statusCode)
                }

                do { return try config.decoder.decode(T.self, from: data) }
                catch { throw APIError.decoding }
            } catch {
                attempt += 1

                // RETRY only when safe (GET) and transient
                if request.method.isIdempotent {
                    // Transient transport errors
                    if let urlErr = error as? URLError,
                       isTransient(urlErr),
                       attempt < backoff.maxAttempts,
                       let wait = backoff.delay(forAttempt: attempt) {
                        try await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                        continue
                    }
                    // Transient HTTP (429/5xx)
                    if case let APIError.http(status) = error,
                       (status == 429 || (500...599).contains(status)),
                       attempt < backoff.maxAttempts,
                       let wait = backoff.delay(forAttempt: attempt) {
                        try await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                        continue
                    }
                }

                // Normalize & rethrow to your simple APIError enum
                if let urlErr = error as? URLError { throw APIError.network(urlErr.code) }
                if error is DecodingError { throw APIError.decoding }
                if let api = error as? APIError { throw api }
                throw error
            }
        }
    }
}
