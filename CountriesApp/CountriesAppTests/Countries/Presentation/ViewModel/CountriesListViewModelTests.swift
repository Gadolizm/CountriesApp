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

        let getAll  = GetAllCountriesStub(result: .success(countries))
        let loadPin = LoadPinnedCodesUseCaseStub(codes: [])       // nothing cached
        let savePin = SavePinnedCodesUseCaseSpy()
        let vm      = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: "BR")
        )

        await vm.load()

        XCTAssertEqual(vm.countries.count, 3)
        XCTAssertEqual(vm.pinned.map(\.alpha2Code), ["BR"])
        // ensure persisted
        XCTAssertEqual(savePin.saved.last, ["BR"])
    }

    // Load + fallback (location denied) → default "BR"
    func test_load_pinsDefaultBrazil_whenLocationDenied() async {
        let countries = makeCountries([
            ("Brazil","BR","Brasília"),
            ("Egypt","EG","Cairo")
        ])

        let getAll  = GetAllCountriesStub(result: .success(countries))
        let loadPin = LoadPinnedCodesUseCaseStub(codes: [])
        let savePin = SavePinnedCodesUseCaseSpy()
        let vm      = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: nil) // denied
        )

        await vm.load()

        XCTAssertEqual(vm.pinned.first?.alpha2Code, "BR")
        XCTAssertEqual(savePin.saved.last, ["BR"])
    }

    // Add up to 5 only (no duplicates)
    func test_pin_allowsUpToFive() async {
        let countries = makeCountries([
            ("A","A1",nil), ("B","B1",nil), ("C","C1",nil),
            ("D","D1",nil), ("E","E1",nil), ("F","F1",nil)
        ])

        // Use case not used in this test
        let getAll  = GetAllCountriesStub(result: .success([]))
        let loadPin = LoadPinnedCodesUseCaseStub(codes: [])
        let savePin = SavePinnedCodesUseCaseSpy()
        let vm      = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: nil)
        )

        for i in 0..<6 { vm.pin(countries[i]) }
        XCTAssertEqual(vm.pinned.count, 5)
        vm.pin(countries[0]) // duplicate ignored
        XCTAssertEqual(vm.pinned.count, 5)

        // last persist call should have 5 codes
        XCTAssertEqual(savePin.saved.last?.count, 5)
    }

    // Remove
    func test_removePinned() async {
        let c = makeCountries([("Brazil","BR",nil)]).first!

        let getAll  = GetAllCountriesStub(result: .success([]))
        let loadPin = LoadPinnedCodesUseCaseStub(codes: [])
        let savePin = SavePinnedCodesUseCaseSpy()
        let vm      = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: nil)
        )

        vm.pin(c)
        vm.removePinned(at: IndexSet(integer: 0))
        XCTAssertTrue(vm.pinned.isEmpty)
        // ensure persist called (possibly with [])
        XCTAssertEqual(savePin.saved.last, [])
    }

    // Search filter
    func test_searchFiltersByName_caseInsensitive() async {
        let countries = makeCountries([
            ("Brazil","BR",nil), ("Bahrain","BH",nil), ("Spain","ES",nil)
        ])

        let getAll  = GetAllCountriesStub(result: .success(countries))
        let loadPin = LoadPinnedCodesUseCaseStub(codes: [])
        let savePin = SavePinnedCodesUseCaseSpy()
        let vm      = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: nil)
        )

        await vm.load()

        vm.query = "bra"
        XCTAssertEqual(vm.filtered.map(\.alpha2Code), ["BR"])

        vm.query = ""
        XCTAssertEqual(vm.filtered.count, 3)
    }

    // Restore pinned from cache (codes -> countries)
    func test_restorePinned_fromCachedCodes() async {
        let countries = makeCountries([("Spain","ES","Madrid"), ("Brazil","BR","Brasília")])
        let getAll    = GetAllCountriesStub(result: .success(countries))
        let loadPin   = LoadPinnedCodesUseCaseStub(codes: ["BR", "ES"])
        let savePin   = SavePinnedCodesUseCaseSpy()
        let vm        = CountriesListViewModel(
            getAll: getAll,
            loadPins: loadPin,
            savePins: savePin,
            locationProvider: LocationProviderStub(code: nil)
        )

        await vm.load() // should restore pinned from codes

        XCTAssertEqual(vm.pinned.map(\.alpha2Code), ["BR", "ES"])
    }
}
