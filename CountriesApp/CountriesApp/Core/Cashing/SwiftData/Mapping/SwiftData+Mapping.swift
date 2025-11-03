//
//  SwiftData+Mapping.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


extension CountrySD {
    static func fromDomain(_ c: Country) -> CountrySD {
        CountrySD(alpha2Code: c.alpha2Code,
                  name: c.name,
                  capital: c.capital,
                  currencyCode: c.currencies?.first?.code)
    }
}

extension Country {
    init(fromSD sd: CountrySD) {
        self.init(
            name: sd.name,
            alpha2Code: sd.alpha2Code,
            capital: sd.capital,
            currencies: sd.currencyCode.map { [Currency(code: $0, name: nil)] }
        )
    }
}
