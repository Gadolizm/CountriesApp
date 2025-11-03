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
        let json = #"""
        [
          {"name":"Brazil","alpha2Code":"BR","capital":"Brasília",
           "currencies":[{"code":"BRL","name":"Brazilian real"}]}
        ]
        """#
        let api  = FakeAPIClient(mode: .success(Data(json.utf8)))
        let repo = CountriesRepositoryImpl(api: api)

        let res = try await repo.fetchAll()
        XCTAssertEqual(res.first?.alpha2Code, "BR")
        XCTAssertEqual(res.first?.currencies?.first?.code, "BRL")
    }

    func test_translatesHTTP500toDomainServer() async {
        let api  = FakeAPIClient(mode: .http(500))
        let repo = CountriesRepositoryImpl(api: api)

        do {
            _ = try await repo.fetchAll()
            XCTFail("expected throw")
        } catch let e as DomainError {
            switch e {
            case .server(let code): XCTAssertEqual(code, 500)
            default: XCTFail("expected .server, got \(e)")
            }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_translatesDecodingToDomainDecoding() async {
        // invalid payload for [CountryDTO]
        let api  = FakeAPIClient(mode: .success(Data(#"{"bad":true}"#.utf8)))
        let repo = CountriesRepositoryImpl(api: api)

        do {
            _ = try await repo.fetchAll()
            XCTFail("expected decoding error")
        } catch let e as DomainError {
            switch e {
            case .decoding: break
            default: XCTFail("expected .decoding, got \(e)")
            }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_translatesNetworkToDomainNetwork() async {
        let api  = FakeAPIClient(mode: .network(.timedOut))
        let repo = CountriesRepositoryImpl(api: api)

        do {
            _ = try await repo.fetchAll()
            XCTFail("expected throw")
        } catch let e as DomainError {
            switch e {
            case .network: break
            default: XCTFail("expected .network, got \(e)")
            }
        } catch { XCTFail("unexpected \(error)") }
    }
}
