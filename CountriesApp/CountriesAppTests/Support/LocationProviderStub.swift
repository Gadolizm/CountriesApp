//
//  LocationProviderStub.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


// MARK: - Test Doubles

@testable import CountriesApp


struct LocationProviderStub: LocationProvidingProtocol {
    let code: String? // "BR" or nil
    func requestCountryCode(_ completion: @escaping (String?) -> Void) { completion(code) }
}

// Helper to make countries quickly
func makeCountries(_ items: [(String,String,String?)]) -> [Country] {
    items.map { Country(name: $0.0, alpha2Code: $0.1, capital: $0.2, currencies: nil) }
}
