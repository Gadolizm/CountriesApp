//
//  ResultBasedCountriesRepositoryStub.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp

struct ResultBasedCountriesRepositoryStub: CountriesRepository {
    let result: Result<[Country], DomainError>
    func fetchAll() async throws -> [Country] { try result.get() }
}
