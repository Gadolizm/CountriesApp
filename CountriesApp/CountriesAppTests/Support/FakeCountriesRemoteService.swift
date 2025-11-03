//
//  FakeCountriesRemoteService.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


@testable import CountriesApp

struct FakeCountriesRemoteService: CountriesRemoteService {
    let result: Result<[CountryDTO], APIError>
    func getAllCountries() async throws -> [CountryDTO] { try result.get() }
}