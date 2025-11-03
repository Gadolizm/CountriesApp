//
//  CountriesRepositoryImplTests.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import XCTest
@testable import CountriesApp

@MainActor
final class CountriesRepositoryImplTests: XCTestCase {

    func test_mapsSuccessDTOtoDomain() async throws {
        // Arrange DTOs
        let dto = CountryDTO(
            name: "Brazil",
            alpha2Code: "BR",
            capital: "Brasília",
            currencies: [CurrencyDTO(code: "BRL", name: "Brazilian real")]
        )
        let remote = FakeCountriesRemoteService(result: .success([dto]))
        let store  = InMemoryCountriesStore()
        let repo   = CountriesRepositoryImpl(remote: remote, store: store)

        // Act
        let res = try await repo.fetchAll(policy: .networkOnly)

        // Assert
        XCTAssertEqual(res.first?.alpha2Code, "BR")
        XCTAssertEqual(res.first?.currencies?.first?.code, "BRL")
    }

    func test_translatesHTTP500toAppServer() async throws {
        let remote = FakeCountriesRemoteService(result: .failure(.http(500)))
        let store  = InMemoryCountriesStore()
        let repo   = CountriesRepositoryImpl(remote: remote, store: store)

        do {
            _ = try await repo.fetchAll(policy: .networkOnly)
            XCTFail("expected throw")
        } catch let e as AppError {
            switch e {
            case .server(let code): XCTAssertEqual(code, 500)
            default: XCTFail("expected .server, got \(e)")
            }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_translatesDecodingToAppDecoding() async throws {
        let remote = FakeCountriesRemoteService(result: .failure(.decoding))
        let store  = InMemoryCountriesStore()
        let repo   = CountriesRepositoryImpl(remote: remote, store: store)

        do {
            _ = try await repo.fetchAll(policy: .networkOnly)
            XCTFail("expected decoding error")
        } catch let e as AppError {
            if case .decoding = e { /* ok */ } else { XCTFail("expected .decoding, got \(e)") }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_translatesNetworkToAppNetwork() async throws {
        let remote = FakeCountriesRemoteService(result: .failure(.network(.timedOut)))
        let store  = InMemoryCountriesStore()
        let repo   = CountriesRepositoryImpl(remote: remote, store: store)

        do {
            _ = try await repo.fetchAll(policy: .networkOnly)
            XCTFail("expected throw")
        } catch let e as AppError {
            if case .network = e { /* ok */ } else { XCTFail("expected .network, got \(e)") }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_cacheFirstReturnsCached_whenNotEmpty() async throws {
        // Prime the cache
        let store  = InMemoryCountriesStore()
        try store.saveCountries([
            Country(name: "Spain", alpha2Code: "ES", capital: "Madrid", currencies: nil)
        ])

        // Remote would fail, but repo should return cache first
        let remote = FakeCountriesRemoteService(result: .failure(.http(500)))
        let repo   = CountriesRepositoryImpl(remote: remote, store: store)

        let res = try await repo.fetchAll(policy: .cacheFirstRefresh)
        XCTAssertEqual(res.first?.alpha2Code, "ES")
    }
}
