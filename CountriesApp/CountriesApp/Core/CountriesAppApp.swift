//
//  CountriesAppApp.swift
//  CountriesApp
//
//  Created by Haitham Gado on 31/10/2025.
//


import SwiftUI
import SwiftData

@main
struct CountriesAppApp: App {
    var body: some Scene {
        WindowGroup {
            BootstrapView()   // builds VM using the environment ModelContext
        }
        .modelContainer(for: [CountrySD.self, PinnedSD.self]) // attach the real container once
    }
}

private struct BootstrapView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        // Build dependencies
        let baseURL = NetworkConfig.defaultBaseURL
        let api     = APIClient(config: NetworkConfig(baseURL: baseURL))
        let repo    = CountriesRepositoryImpl(api: api)
        let useCase = GetAllCountries(repo: repo)

        let store   = SwiftDataCountriesStore(context: context)

        // Hand the VM to the view
        CountriesListView(
            vm: CountriesListViewModel(
                getAll: useCase,
                persistence: store
            )
        )
    }
}
