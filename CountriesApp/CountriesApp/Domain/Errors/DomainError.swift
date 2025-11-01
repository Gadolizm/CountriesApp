//
//  DomainError.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

/// App-facing errors (clean, UI-friendly)
enum DomainError: Error {
    case network           // connectivity / timeout / DNS
    case server(status: Int) // non-2xx HTTP codes if you want to surface them
    case decoding          // JSON shape mismatch
    case unknown
}

extension DomainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network:
            return "Network issue. Please try again."
        case .server(let s):
            return "Server error (code \(s)). Try again later."
        case .decoding:
            return "We couldn't read the data."
        case .unknown:
            return "Something went wrong."
        }
    }
}