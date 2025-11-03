//
//  GetAllCountriesStub.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp

struct GetAllCountriesStub: GetAllCountriesUseCase {
    
    let result: Result<[Country], AppError>
    func callAsFunction(policy: CountriesApp.FetchPolicy) async throws -> [Country] { try result.get() }
}
