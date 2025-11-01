//
//  LocationProvidingProtocol.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

protocol LocationProvidingProtocol {
    /// Returns ISO country code (e.g., "EG") or nil on failure/denied.
    func requestCountryCode(_ completion: @escaping (String?) -> Void)
}
