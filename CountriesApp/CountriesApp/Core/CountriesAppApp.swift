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
        WindowGroup { BootstrapView() }
            .modelContainer(for: [CountrySD.self, PinnedSD.self])
    }
}

private struct BootstrapView: View {
    @Environment(\.modelContext) private var context
    @State private var vm: CountriesListViewModel?
    
    var body: some View {
        Group {
            if let vm {
                CountriesListView(vm: vm)
            } else {
                ProgressView("Loading…")
                    .task { await buildOnce() }
            }
        }
    }
    
    @MainActor
    private func buildOnce() async {
        do {
            // Network (safe defaults; no force unwraps)
            let config = try NetworkConfig()
            let api    = APIClient(config: config)
            
            // Persistence (SwiftData-backed)
            let store  = SwiftDataCountriesStore(context: context)
            
            let remote = CountriesRemoteServiceImpl(api: api)
            
            // Repository (owns cache + network + pinned passthrough)
            let repo = CountriesRepositoryImpl(remote: remote, store: store)
            
            // Use case (domain)
            let getAll   = GetAllCountries(repo: repo)
            let loadPins = LoadPinnedCodes(repo: repo)
            let savePins = SavePinnedCodes(repo: repo)
            
            // ViewModel (Option A: needs repo for pinned load/save)
            vm = CountriesListViewModel(getAll: getAll, loadPins: loadPins, savePins: savePins)
        } catch {
            let emptyRepo = EmptyCountriesRepo()
            vm = CountriesListViewModel(
                getAll: GetAllCountries(repo: emptyRepo),
                loadPins: LoadPinnedCodes(repo: emptyRepo),
                savePins: SavePinnedCodes(repo: emptyRepo)
            )
        }
    }
}

// Tiny fallback repo used only on bootstrap failure
private struct EmptyCountriesRepo: CountriesRepository {
    @MainActor func loadPinnedCodes() -> [String] { [] }
    @MainActor func savePinnedCodes(_ codes: [String]) throws { /* no-op */ }
    func fetchAll(policy: FetchPolicy) async throws -> [Country] { [] }
}
