//
//  CountriesListViewModelTests.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import XCTest
@testable import CountriesApp

@MainActor
final class CountriesListViewModelTests: XCTestCase {

    // Load + auto-pin (location allowed)
    func test_load_autoPinsCurrentCountry_whenLocationAllowed() async {
        let countries = makeCountries([
            ("Brazil", "BR", "Brasília"),
            ("Egypt",  "EG", "Cairo"),
            ("Spain",  "ES", "Madrid"),
        ])
        let repo = ResultBasedCountriesRepositoryStub(result: .success(countries))
        let use  = GetAllCountries(repo: repo)
        let vm   = CountriesListViewModel(getAll: use, locationProvider: LocationProviderStub(code: "BR"))

        await vm.load()

        XCTAssertEqual(vm.countries.count, 3)
        XCTAssertEqual(vm.pinned.map(\.alpha2Code), ["BR"])
    }

    // Load + fallback (location denied)
    func test_load_pinsDefaultBrazil_whenLocationDenied() async {
        let countries = makeCountries([
            ("Brazil", "BR", "Brasília"),
            ("Egypt",  "EG", "Cairo"),
        ])
        let repo = ResultBasedCountriesRepositoryStub(result: .success(countries))
        let use  = GetAllCountries(repo: repo)
        let vm   = CountriesListViewModel(getAll: use, locationProvider: LocationProviderStub(code: nil))

        await vm.load()

        XCTAssertEqual(vm.pinned.first?.alpha2Code, "BR")
    }

    // Add up to 5 only (no duplicates)
    func test_pin_allowsUpToFive() async {
        let countries = makeCountries([
            ("A","A1",nil), ("B","B1",nil), ("C","C1",nil),
            ("D","D1",nil), ("E","E1",nil), ("F","F1",nil)
        ])
        let repo = ResultBasedCountriesRepositoryStub(result: .success(countries))
        let use  = GetAllCountries(repo: repo)
        let vm   = CountriesListViewModel(getAll: use, locationProvider: LocationProviderStub(code: nil))

        // no need to load for this logic
        vm.pinned = []
        for i in 0..<6 { vm.pin(countries[i]) }   // try to add 6
        XCTAssertEqual(vm.pinned.count, 5)

        vm.pin(countries[0])                      // duplicate ignored
        XCTAssertEqual(vm.pinned.count, 5)
    }

    // Remove
    func test_removePinned() async {
        let countries = makeCountries([("Brazil","BR",nil)])
        let repo = ResultBasedCountriesRepositoryStub(result: .success(countries))
        let use  = GetAllCountries(repo: repo)
        let vm   = CountriesListViewModel(getAll: use, locationProvider: LocationProviderStub(code: nil))

        vm.pinned = countries
        vm.removePinned(at: IndexSet(integer: 0))
        XCTAssertTrue(vm.pinned.isEmpty)
    }

    // Search filter
    func test_searchFiltersByName_caseInsensitive() async {
        let countries = makeCountries([
            ("Brazil","BR",nil), ("Bahrain","BH",nil), ("Spain","ES",nil)
        ])
        let repo = ResultBasedCountriesRepositoryStub(result: .success(countries))
        let use  = GetAllCountries(repo: repo)
        let vm   = CountriesListViewModel(getAll: use, locationProvider: LocationProviderStub(code: nil))

        vm.countries = countries
        vm.query = "bra"
        XCTAssertEqual(vm.filtered.map(\.alpha2Code), ["BR"])

        vm.query = ""
        XCTAssertEqual(vm.filtered.count, 3)
    }
}
