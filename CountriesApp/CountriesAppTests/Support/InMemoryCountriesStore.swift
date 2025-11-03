//
//  InMemoryCountriesStore.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import SwiftData
@testable import CountriesApp

@MainActor
final class InMemoryCountriesStore: CountriesPersistence {
    private var countries: [Country] = []
    private var pinned: [String] = []

    func loadCountries() -> [Country] { countries }

    func saveCountries(_ list: [Country]) throws { countries = list }

    func loadPinnedCodes() -> [String] { pinned }

    func savePinnedCodes(_ codes: [String]) throws { pinned = codes }
}