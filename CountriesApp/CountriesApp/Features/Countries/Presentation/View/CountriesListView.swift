//
//  CountriesListView.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct CountriesListView: View {
    @Environment(\.modelContext) private var context
    @StateObject var vm: CountriesListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 8) {
                        Text(msg).multilineTextAlignment(.center)
                        Button("Retry") { Task { await vm.load() } }
                    }.padding()
                } else {
                    List {
                        Section("My Countries (\(vm.pinned.count)/5)") {
                            if vm.pinned.isEmpty {
                                Text("No countries yet").foregroundStyle(.secondary)
                            } else {
                                ForEach(vm.pinned) { country in
                                    NavigationLink(value: country) {
                                        VStack(alignment: .leading) {
                                            Text(country.name).font(.headline)
                                            Text(country.capital ?? "—").font(.subheadline)
                                        }
                                    }
                                }
                                .onDelete(perform: vm.removePinned)
                            }
                        }
                        Section("All Countries") {
                            ForEach(vm.filtered) { country in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(country.name)
                                        Text(country.capital ?? "—").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("Add") { vm.pin(country) }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(!vm.canPin(country))
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Country.self) { CountryDetailView(country: $0) }
                }
            }
            .searchable(text: $vm.query)
            .navigationTitle("Countries")
            .task { await vm.load() }
        }
    }
}
