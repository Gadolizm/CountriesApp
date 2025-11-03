//
//  CountriesRemoteServiceImpl.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


import Foundation

struct CountriesRemoteServiceImpl: CountriesRemoteService {
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func getAllCountries() async throws -> [CountryDTO] {
        try await api.perform(
            APIRequest(
                path: "/v2/all",
                method: .GET,
                query: ["fields": "name,alpha2Code,capital,currencies,region"]
            )
        )
    }
}