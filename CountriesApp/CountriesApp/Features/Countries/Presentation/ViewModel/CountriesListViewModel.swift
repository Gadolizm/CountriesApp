//
//  CountriesListViewModel.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//

import Foundation
import Combine

@MainActor
final class CountriesListViewModel: ObservableObject, CountriesListViewModelingProtocol {
    // Fetching goes through the use case (clean)
    private let getAll: GetAllCountriesUseCase
    private let loadPins: LoadPinnedCodesUseCase
    private let savePins: SavePinnedCodesUseCase
    private let locationProvider: LocationProvidingProtocol


    @Published private(set) var countries: [Country] = []
    @Published private(set) var pinned: [Country] = []
    @Published var query = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let maxPinned = 5
    private let defaultCountryCode = "BR"

    init(getAll: GetAllCountriesUseCase,
         loadPins: LoadPinnedCodesUseCase,
         savePins: SavePinnedCodesUseCase,
         locationProvider: LocationProvidingProtocol? = nil) {
        self.getAll = getAll
        self.loadPins = loadPins
        self.savePins = savePins
        self.locationProvider = locationProvider ?? LocationProvider()
    }

    // MARK: - Loading (cache → network)
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1) Show cache instantly
            let cached = try await getAll(policy: .cacheOnly)
            if !cached.isEmpty {
                countries = cached
                restorePinned()
                if pinned.isEmpty { await autoPinFirstCountry() }
            }

            // 2) Refresh from network (repo persists countries)
            let fresh = try await getAll(policy: .networkOnly)
            countries = fresh
            if pinned.isEmpty { await autoPinFirstCountry() }

        } catch {
            if countries.isEmpty {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load countries."
            }
        }
    }

    // MARK: - Derived UI
    var filtered: [Country] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return q.isEmpty ? countries : countries.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    // MARK: - Pinning
    func canPin(_ c: Country) -> Bool { !pinned.contains(c) && pinned.count < maxPinned }

    func pin(_ c: Country) {
        guard canPin(c) else { return }
        pinned.append(c)
        persistPinned()
    }

    func removePinned(at offsets: IndexSet) {
        for i in offsets.sorted(by: >) where pinned.indices.contains(i) { pinned.remove(at: i) }
        persistPinned()
    }
    
    private func persistPinned() {
        try? savePins.execute(pinned.prefix(5).map(\.alpha2Code))
    }

    private func restorePinned() {
        let codes = loadPins.execute().map { $0.uppercased() }
        // map codes → current countries list
        let dict = Dictionary(uniqueKeysWithValues: countries.map { ($0.alpha2Code.uppercased(), $0) })
        var seen = Set<String>()
        pinned = codes.compactMap { c in
            guard let x = dict[c], seen.insert(c).inserted else { return nil }
            return x
        }.prefix(5).map { $0 }
    }


    // MARK: - Auto-pin on first launch
    private func autoPinFirstCountry() async {
        guard pinned.isEmpty else { return }
        await withCheckedContinuation { [weak self] (cont: CheckedContinuation<Void, Never>) in
            self?.locationProvider.requestCountryCode { code in
                Task { @MainActor in
                    guard let self else { cont.resume(); return }
                    let target = (code ?? self.defaultCountryCode).uppercased()
                    if let m = self.countries.first(where: { $0.alpha2Code.uppercased() == target }) {
                        self.pinned = [m]
                    } else if let f = self.countries.first(where: { $0.alpha2Code.uppercased() == self.defaultCountryCode }) {
                        self.pinned = [f]
                    }
                    self.persistPinned()      // save auto-pin
                    cont.resume()
                }
            }
        }
    }
}
