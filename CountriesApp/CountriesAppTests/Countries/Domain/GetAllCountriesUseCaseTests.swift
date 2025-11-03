//
//  GetAllCountriesUseCaseTests.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import XCTest
@testable import CountriesApp


final class GetAllCountriesUseCaseTests: XCTestCase {

    func test_useCase_returnsCountries_onSuccess() async throws {
        let countries = await [
            Country(name: "Brazil", alpha2Code: "BR", capital: "Brasília", currencies: nil),
            Country(name: "Spain",  alpha2Code: "ES", capital: "Madrid",   currencies: nil)
        ]
        let use = await GetAllCountries(repo: ResultBasedCountriesRepositoryStub(result: .success(countries)))
        let got = try await use()
        let codes = await MainActor.run { got.map { $0.alpha2Code } }
        XCTAssertEqual(codes, ["BR", "ES"])
    }

    func test_useCase_propagatesDomainError() async {
        let use = await GetAllCountries(repo: ResultBasedCountriesRepositoryStub(result: .failure(.network)))

        do {
            _ = try await use()
            XCTFail("Expected to throw")
        } catch let error as DomainError {
            // Don’t require Equatable conformance
            switch error {
            case .network:
                // OK
                break
            default:
                XCTFail("Expected .network, got \(error)")
            }
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }
}
