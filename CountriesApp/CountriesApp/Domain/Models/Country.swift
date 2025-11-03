//
//  Country.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//

public struct Country: Identifiable, Codable, Equatable, Hashable {
    public let name: String
    public let alpha2Code: String
    public let capital: String?
    public let currencies: [Currency]?   // ← uses the type above
    public var id: String { alpha2Code }

    public init(name: String, alpha2Code: String, capital: String?, currencies: [Currency]?) {
        self.name = name
        self.alpha2Code = alpha2Code
        self.capital = capital
        self.currencies = currencies
    }
}
