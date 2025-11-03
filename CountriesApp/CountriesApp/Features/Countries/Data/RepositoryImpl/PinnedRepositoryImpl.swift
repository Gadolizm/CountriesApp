//
//  PinnedRepositoryImpl.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


final class PinnedRepositoryImpl: PinnedRepository {
    private let store: CountriesPersistence
    init(store: CountriesPersistence) { self.store = store }
    @MainActor func loadPinnedCodes() -> [String] { store.loadPinnedCodes() }
    @MainActor func savePinnedCodes(_ codes: [String]) throws { try store.savePinnedCodes(codes) }
}