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

    // Dependencies
    private let getAll: GetAllCountries
    private let locationProvider: LocationProvidingProtocol

    // UI State
    @Published var countries: [Country] = []
    @Published var pinned: [Country] = []           // main view list (max 5)
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Config
    private let maxPinned = 5
    private let defaultCountryCode = "BR" // fallback if user denies (Brazil)

    init(getAll: GetAllCountries, locationProvider: LocationProvidingProtocol? = nil) {
        self.getAll = getAll
        self.locationProvider = locationProvider ?? LocationProvider()
    }

    func load() async {
        isLoading = true; errorMessage = nil
        do {
            countries = try await getAll()
            // Auto pin first by current location (or fallback)
            await autoPinFirstCountry()
        } catch let e as LocalizedError {
            errorMessage = e.errorDescription ?? "Error"
        } catch {
            errorMessage = "Unexpected error"
        }
        isLoading = false
    }

    private func autoPinFirstCountry() async {
        guard pinned.isEmpty else { return }
        await withCheckedContinuation { [weak self] (cont: CheckedContinuation<Void, Never>) in
            self?.locationProvider.requestCountryCode { code in
                Task { @MainActor in
                    let targetCode = (code ?? self?.defaultCountryCode)?.uppercased()
                    if let code = targetCode,
                       let match = self?.countries.first(where: { $0.alpha2Code.uppercased() == code }) {
                        self?.pinned = [match]
                    } else if let fallback = self?.countries.first(where: { $0.alpha2Code.uppercased() == self?.defaultCountryCode }) {
                        self?.pinned = [fallback]
                    }
                    cont.resume()
                }
            }
        }
    }

    var filtered: [Country] {
        guard !query.isEmpty else { return countries }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Actions
    func canPin(_ country: Country) -> Bool {
        !pinned.contains(country) && pinned.count < maxPinned
    }

    func pin(_ country: Country) {
        guard canPin(country) else { return }
        pinned.append(country)
    }

    func removePinned(at offsets: IndexSet) {
        pinned.remove(atOffsets: offsets)
    }
}
