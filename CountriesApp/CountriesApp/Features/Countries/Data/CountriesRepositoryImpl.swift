//
//  CountriesRepositoryImpl.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


final class CountriesRepositoryImpl: CountriesRepository {
    private let api: APIClient
    init(api: APIClient) { self.api = api }

    func fetchAll() async throws -> [Country] {
        let req = APIRequest(
            path: "/v2/all",
            query: ["fields":"name,alpha2Code,capital,currencies,region"] // <= required by API
        )
        do {
            let dtos: [CountryDTO] = try await api.perform(req)
            return dtos.map(CountryMapper.map)
        } catch let e as APIError {
            switch e {
            case .network:          throw DomainError.network
            case .http(let s):      throw DomainError.server(status: s)
            case .decoding:         throw DomainError.decoding
            }
        } catch { throw DomainError.unknown }
    }
}