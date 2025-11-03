//
//  CountriesListViewModel.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation
import Combine
import SwiftUI

@MainActor
final class CountriesListViewModel: ObservableObject, CountriesListViewModelingProtocol {
    private let getAll: GetAllCountries
    private let locationProvider: LocationProvidingProtocol
    private let persistence: CountriesPersistence?   // ← inject

    @Published private(set) var countries: [Country] = []
    @Published private(set) var pinned: [Country] = []
    @Published var query = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let maxPinned = 5
    private let defaultCountryCode = "BR"

    init(getAll: GetAllCountries,
         locationProvider: LocationProvidingProtocol? = nil,
         persistence: CountriesPersistence? = nil) {
        self.getAll = getAll
        self.locationProvider = locationProvider ?? LocationProvider()
        self.persistence = persistence
    }

    // MARK: Public API
    func load() async {
        isLoading = true; errorMessage = nil
        preloadFromCache()

        do {
            let fetched = try await getAll()
            countries = fetched
            try? persistence?.saveCountries(fetched)
            await autoPinFirstCountry()
            try? persistPinnedSnapshot()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load countries."
        }
        isLoading = false
    }

    var filtered: [Country] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty ? countries : countries.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    func canPin(_ country: Country) -> Bool {
        !pinned.contains(country) && pinned.count < maxPinned
    }

    func pin(_ country: Country) {
        guard canPin(country) else { return }
        pinned.append(country)
        try? persistPinnedSnapshot()
    }

    func removePinned(at offsets: IndexSet) {
        pinned.remove(atOffsets: offsets)
        try? persistPinnedSnapshot()
    }

    // MARK: Private
    private func preloadFromCache() {
        guard let store = persistence else { return }
        let cached = store.loadCountries()
        if !cached.isEmpty { countries = cached }

        let codes = store.loadPinnedCodes().map { $0.uppercased() }
        if !codes.isEmpty {
            let dict = Dictionary(uniqueKeysWithValues: countries.map { ($0.alpha2Code.uppercased(), $0) })
            pinned = codes.compactMap { dict[$0] }.prefix(maxPinned).map { $0 }
        }
    }

    private func persistPinnedSnapshot() throws {
        guard let store = persistence else { return }
        try store.savePinnedCodes(pinned.prefix(maxPinned).map(\.alpha2Code))
    }

    private func autoPinFirstCountry() async {
        guard pinned.isEmpty else { return }
        await withCheckedContinuation { [weak self] (cont: CheckedContinuation<Void, Never>) in
            self?.locationProvider.requestCountryCode { code in
                Task { @MainActor in
                    guard let self else { cont.resume(); return }
                    let target = (code ?? self.defaultCountryCode).uppercased()
                    if let match = self.countries.first(where: { $0.alpha2Code.uppercased() == target }) {
                        self.pinned = [match]
                    } else if let fallback = self.countries.first(where: { $0.alpha2Code.uppercased() == self.defaultCountryCode }) {
                        self.pinned = [fallback]
                    }
                    cont.resume()
                }
            }
        }
    }
}
