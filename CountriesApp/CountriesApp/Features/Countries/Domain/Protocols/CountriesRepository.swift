//
//  CountriesRepository.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


public protocol CountriesRepository {
    func fetchAll(policy: FetchPolicy) async throws -> [Country]
    @MainActor func loadPinnedCodes() -> [String]
    @MainActor func savePinnedCodes(_ codes: [String]) throws
}
