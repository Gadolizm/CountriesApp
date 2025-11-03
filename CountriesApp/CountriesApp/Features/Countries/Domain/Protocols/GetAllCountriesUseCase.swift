//
//  GetAllCountriesUseCase.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public protocol GetAllCountriesUseCase {
    func callAsFunction(policy: FetchPolicy) async throws -> [Country]
}
