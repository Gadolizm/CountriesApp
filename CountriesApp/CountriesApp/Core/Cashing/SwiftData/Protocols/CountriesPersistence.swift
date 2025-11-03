//
//  CountriesPersistence.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


protocol CountriesPersistence {
    /// Returns cached countries (domain model) if any
    func loadCountries() -> [Country]
    /// Persist/Upsert countries snapshot
    func saveCountries(_ countries: [Country]) throws
    /// Pinned list as ordered alpha2 codes (max 5)
    func loadPinnedCodes() -> [String]
    /// Persist ordered pinned codes (max 5)
    func savePinnedCodes(_ codes: [String]) throws
}