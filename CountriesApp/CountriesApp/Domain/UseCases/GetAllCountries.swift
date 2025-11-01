//
//  GetAllCountries.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


struct GetAllCountries {
    private let repo: CountriesRepository
    init(repo: CountriesRepository) { self.repo = repo }
    func callAsFunction() async throws -> [Country] { try await repo.fetchAll() }
}