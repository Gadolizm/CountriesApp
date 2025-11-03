//
//  CountryMapper.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


enum CountryMapper {
    static func map(_ d: CountryDTO) -> Country {
        Country(
            name: d.name,
            alpha2Code: d.alpha2Code,
            capital: d.capital,
            currencies: d.currencies?.compactMap {
                guard let code = $0.code, !code.isEmpty else { return nil }
                return Currency(code: code, name: $0.name)
            }
        )
    }
}
