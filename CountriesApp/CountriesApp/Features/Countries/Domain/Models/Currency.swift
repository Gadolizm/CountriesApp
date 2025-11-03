//
//  Currency.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import Foundation

public struct Currency: Codable, Equatable, Hashable {
    public let code: String        // e.g., "BRL"
    public let name: String?       // e.g., "Brazilian real"

    public init(code: String, name: String?) {
        self.code = code
        self.name = name
    }
}