//
//  CountryMapper.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


enum CountryMapper {
    static func map(_ d: CountryDTO) -> Country {
        .init(name: d.name,
              alpha2Code: d.alpha2Code,
              capital: d.capital,
              currencies: d.currencies?.map { .init(code: $0.code, name: $0.name) })
    }
}