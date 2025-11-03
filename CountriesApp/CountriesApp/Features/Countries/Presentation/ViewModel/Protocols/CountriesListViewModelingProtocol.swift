//
//  CountriesListViewModelingProtocol.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

@MainActor
protocol CountriesListViewModelingProtocol: ObservableObject {
    var countries: [Country] { get }
    var pinned: [Country] { get }
    var query: String { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func load() async
    func canPin(_ country: Country) -> Bool
    func pin(_ country: Country)
    func removePinned(at offsets: IndexSet)
}
