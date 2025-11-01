//
//  CountryDTO.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


struct CountryDTO: Decodable {
    let name: String
    let alpha2Code: String
    let capital: String?
    let currencies: [Cur]?
    struct Cur: Decodable { let code: String?; let name: String? }
}