//
//  CountryDetailView.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


// Presentation/CountryDetailView.swift
import SwiftUI

struct CountryDetailView: View {
    let country: Country
    var primaryCurrency: Country.Currency? { country.currencies?.first }

    var body: some View {
        List {
            Section("Country") {
                Text(country.name)
                Text("Code: \(country.alpha2Code)")
            }
            Section("Capital") {
                Text(country.capital ?? "—")
            }
            Section("Currency") {
                if let cur = primaryCurrency {
                    Text([cur.name, cur.code].compactMap { $0 }.joined(separator: " · "))
                } else {
                    Text("—")
                }
            }
        }
        .navigationTitle(country.name)
    }
}
