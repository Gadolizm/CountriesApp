//
//  Country.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


struct Country: Identifiable, Hashable {
    let id: String
    let name: String
    let alpha2Code: String
    let capital: String?
    let currencies: [Currency]?
    struct Currency: Hashable { let code: String?; let name: String? }
    init(name: String, alpha2Code: String, capital: String?, currencies: [Currency]?) {
        self.id = alpha2Code; self.name = name; self.alpha2Code = alpha2Code
        self.capital = capital; self.currencies = currencies
    }
}
