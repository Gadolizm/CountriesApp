//
//  FetchPolicy.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public enum FetchPolicy {
    case cacheFirstRefresh   // show cache immediately, then refresh
    case networkOnly
    case cacheOnly
}