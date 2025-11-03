//
//  CountriesRepositoryImpl.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//

final class CountriesRepositoryImpl: CountriesRepository {
    private let remote: CountriesRemoteService
    private let store: CountriesPersistence   // SwiftData-backed

    init(remote: CountriesRemoteService, store: CountriesPersistence) {
        self.remote = remote
        self.store  = store
    }

    func fetchAll(policy: FetchPolicy) async throws -> [Country] {
        switch policy {
        case .cacheOnly:
            return store.loadCountries()

        case .networkOnly:
            do {
                let dtos   = try await remote.getAllCountries()
                let mapped = dtos.map(CountryMapper.map)
                try? store.saveCountries(mapped)
                return mapped
            } catch let e as APIError {
                throw mapAPIErrorToAppError(e)
            }

        case .cacheFirstRefresh:
            let cached = store.loadCountries()
            if !cached.isEmpty { return cached }

            do {
                let dtos   = try await remote.getAllCountries()
                let mapped = dtos.map(CountryMapper.map)
                try? store.saveCountries(mapped)
                return mapped
            } catch let e as APIError {
                throw mapAPIErrorToAppError(e)
            }
        }
    }

    @MainActor func loadPinnedCodes() -> [String] { store.loadPinnedCodes() }
    @MainActor func savePinnedCodes(_ codes: [String]) throws { try store.savePinnedCodes(codes) }
}

// MARK: - Private
private func mapAPIErrorToAppError(_ e: APIError) -> AppError {
    switch e {
    case .network:          return .network
    case .http(let status): return .server(status: status)
    case .decoding:         return .decoding
    }
}
