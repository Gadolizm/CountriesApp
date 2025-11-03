//
//  ResultBasedCountriesRepositoryStub.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp

import XCTest
@testable import CountriesApp

final class ResultBasedCountriesRepositoryStub: CountriesRepository {
    // Controlled result for fetchAll()
    let result: Result<[Country], AppError>

    // Simple in-memory storage for pinned codes (observable in tests)
    @MainActor private(set) var storedPins: [String]

    init(result: Result<[Country], AppError>, pins: [String] = []) {
        self.result = result
        self.storedPins = pins
    }

    // MARK: - CountriesRepository

    func fetchAll(policy: FetchPolicy) async throws -> [Country] {
        try result.get()
    }

    @MainActor
    func loadPinnedCodes() -> [String] {
        storedPins
    }

    @MainActor
    func savePinnedCodes(_ codes: [String]) throws {
        storedPins = codes
    }
}
