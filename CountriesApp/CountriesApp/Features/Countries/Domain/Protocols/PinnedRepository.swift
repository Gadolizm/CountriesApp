//
//  PinnedRepository.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public protocol PinnedRepository {
    @MainActor func loadPinnedCodes() -> [String]
    @MainActor func savePinnedCodes(_ codes: [String]) throws
}