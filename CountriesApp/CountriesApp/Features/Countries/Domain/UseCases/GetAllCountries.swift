//
//  GetAllCountries.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


public struct GetAllCountries: GetAllCountriesUseCase {
    private let repo: CountriesRepository
    public init(repo: CountriesRepository) { self.repo = repo }
    public func callAsFunction(policy: FetchPolicy = .cacheFirstRefresh) async throws -> [Country] {
        try await repo.fetchAll(policy: policy)
    }
}
