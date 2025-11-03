//
//  CountryDTO.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


struct CountryDTO: Codable {
    let name: String
    let alpha2Code: String
    let capital: String?
    let currencies: [CurrencyDTO]?   // <- array, not currencyCode
}
