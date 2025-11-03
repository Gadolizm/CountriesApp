//
//  CountriesRemoteService.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import Foundation

protocol CountriesRemoteService {
    /// Returns raw DTOs from the REST Countries API
    func getAllCountries() async throws -> [CountryDTO]
}