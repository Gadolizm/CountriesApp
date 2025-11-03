//
//  APIError.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

enum APIError: Error {
    case network(URLError.Code)   // <- "network"
    case http(Int)                // <- "http"
    case decoding
}
