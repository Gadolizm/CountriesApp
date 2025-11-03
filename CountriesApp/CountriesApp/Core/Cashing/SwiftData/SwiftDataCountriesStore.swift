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
        let desc = FetchDescriptor<CountrySD>(sortBy: [SortDescriptor(\.name)])
        let rows = (try? context.fetch(desc)) ?? []
        return rows.map {
            Country(
                name: $0.name,
                alpha2Code: $0.alpha2Code,
                capital: $0.capital,
                currencies: $0.currencyCode.map { [Currency(code: $0, name: nil)] }
            )
        }
    }

    func saveCountries(_ list: [Country]) throws {
        // index existing
        let existing = try context.fetch(FetchDescriptor<CountrySD>())
        let byCode = Dictionary(uniqueKeysWithValues: existing.map { ($0.alpha2Code.uppercased(), $0) })

        for c in list {
            let code = c.alpha2Code.uppercased()
            if let row = byCode[code] {
                row.name = c.name
                row.capital = c.capital
                row.currencyCode = c.currencies?.first?.code
            } else {
                context.insert(CountrySD(
                    alpha2Code: code,
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
        return rows.map { $0.alpha2Code }
    }

    func savePinnedCodes(_ codes: [String]) throws {
        // Clear and rewrite small list
        let rows = try context.fetch(FetchDescriptor<PinnedSD>())
        rows.forEach { context.delete($0) }

        for (i, code) in codes.prefix(5).enumerated() {
            context.insert(PinnedSD(alpha2Code: code, order: i))
        }
        try context.save()
    }
}
