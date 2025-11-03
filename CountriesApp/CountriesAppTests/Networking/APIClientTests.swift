//
//  APIClientTests.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import XCTest
@testable import CountriesApp


final class APIClientTests: XCTestCase {

    private func makeClient(decoder: JSONDecoder = .init()) -> APIClient {
        let cfg = NetworkConfig(
            baseURL: URL(string: "https://example.com")!,
            session: makeMockSession(),
            decoder: decoder
        )
        return APIClient(config: cfg) // ← no backoff param anymore
    }

    func test_decodes200OK() async throws {
        MockURLProtocol.handler = { _ in
            let url  = URL(string: "https://example.com/v2/all?fields=a")!
            let resp = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (resp, Data(#"[{"x":1}]"#.utf8))
        }

        let client = makeClient()
        let req = APIRequest(path: "/v2/all", method: .GET, query: ["fields":"a"])
        let v: [[String:Int]] = try await client.perform(req)
        XCTAssertEqual(v.first?["x"], 1)
    }

    func test_mapsHTTPError() async {
        MockURLProtocol.handler = { _ in
            let resp = HTTPURLResponse(url: URL(string:"https://example.com/x")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (resp, Data())
        }

        let client = makeClient()
        do {
            let _: [String:String] = try await client.perform(.init(path: "/x"))
            XCTFail("expected throw")
        } catch let e as APIError {
            if case .http(let code) = e { XCTAssertEqual(code, 500) } else { XCTFail("got \(e)") }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_mapsTransportErrorToNetwork() async {
        MockURLProtocol.handler = { _ in throw URLError(.timedOut) }

        let client = makeClient()
        do {
            let _: [String:String] = try await client.perform(.init(path: "/x"))
            XCTFail("expected throw")
        } catch let e as APIError {
            if case .network(let code) = e { XCTAssertEqual(code, .timedOut) } else { XCTFail("got \(e)") }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_decodingErrorMapped() async {
        MockURLProtocol.handler = { _ in
            let resp = HTTPURLResponse(url: URL(string:"https://example.com/x")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (resp, Data(#"{"oops":true}"#.utf8)) // invalid for expected type
        }

        let client = makeClient()
        do {
            let _: [[String:String]] = try await client.perform(.init(path: "/x"))
            XCTFail("expected decoding error")
        } catch let e as APIError {
            if case .decoding = e { /* ok */ } else { XCTFail("got \(e)") }
        } catch { XCTFail("unexpected \(error)") }
    }

    func test_retriesGetOn5xxThenSucceeds() async throws {
        var calls = 0
        MockURLProtocol.handler = { _ in
            calls += 1
            let url = URL(string:"https://example.com/x")!
            if calls == 1 {
                let r = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
                return (r, Data())
            } else {
                let r = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (r, Data(#"[{"ok":1}]"#.utf8))
            }
        }

        let client = makeClient()
        // Note: this will wait ~0.3s due to built-in backoff
        let v: [[String:Int]] = try await client.perform(.init(path: "/x", method: .GET))
        XCTAssertEqual(v.first?["ok"], 1)
        XCTAssertEqual(calls, 2)
    }

    func test_doesNotRetryOnPost() async {
        var calls = 0
        MockURLProtocol.handler = { _ in
            calls += 1
            let r = HTTPURLResponse(url: URL(string:"https://example.com/x")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (r, Data())
        }

        let client = makeClient()
        do {
            let _: [String:String] = try await client.perform(.init(path: "/x", method: .POST, body: Data()))
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(calls, 1) // POST must not retry
        }
    }
}
