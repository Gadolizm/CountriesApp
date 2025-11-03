//
//  SwiftDataCountriesStore.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import SwiftData
import Foundation

@MainActor
final class SwiftDataCountriesStore: CountriesPersistence {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func loadCountries() -> [Country] {
        let rows = (try? context.fetch(FetchDescriptor<CountrySD>(sortBy: [SortDescriptor(\.name)]))) ?? []
        return rows.map {
            Country(
                name: $0.name,
                alpha2Code: $0.alpha2Code,
                capital: $0.capital,
                currencies: $0.currencyCode.map { [Currency(code: $0, name: nil)] }
            )
        }
    }

    func saveCountries(_ countries: [Country]) throws {
        let existing = try Dictionary(uniqueKeysWithValues:
            context.fetch(FetchDescriptor<CountrySD>()).map { ($0.alpha2Code, $0) }
        )
        for c in countries {
            if let row = existing[c.alpha2Code] {
                row.name = c.name
                row.capital = c.capital
                row.currencyCode = c.currencies?.first?.code
            } else {
                context.insert(CountrySD(
                    alpha2Code: c.alpha2Code,
                    name: c.name,
                    capital: c.capital,
                    currencyCode: c.currencies?.first?.code
                ))
            }
        }
        try context.save()
    }

    func loadPinnedCodes() -> [String] {
        let rows = (try? context.fetch(FetchDescriptor<PinnedSD>(sortBy: [SortDescriptor(\.order)]))) ?? []
        return rows.map(\.alpha2Code)
    }

    func savePinnedCodes(_ codes: [String]) throws {
        if let rows = try? context.fetch(FetchDescriptor<PinnedSD>()) {
            rows.forEach { context.delete($0) }
        }
        for (i, code) in codes.prefix(5).enumerated() {
            context.insert(PinnedSD(alpha2Code: code, order: i))
        }
        try context.save()
    }
}
