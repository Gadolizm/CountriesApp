//
//  HTTPMethod.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


enum HTTPMethod: String {
    case GET, POST
    var isIdempotent: Bool { self == .GET }
}
