//
//  CountrySD.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import SwiftData

@Model
final class CountrySD {
    @Attribute(.unique) var alpha2Code: String
    var name: String
    var capital: String?
    var currencyCode: String?

    init(alpha2Code: String, name: String, capital: String?, currencyCode: String?) {
        self.alpha2Code = alpha2Code
        self.name = name
        self.capital = capital
        self.currencyCode = currencyCode
    }
}


