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
            let api     = APIClient(config: NetworkConfig(baseURL: NetworkConfig.defaultBaseURL))
            let repo    = CountriesRepositoryImpl(api: api)
            let useCase = GetAllCountries(repo: repo)
            CountriesListView(vm: .init(getAll: useCase))
        }
    }
}



