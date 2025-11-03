//
//  SavePinnedCodes.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public final class SavePinnedCodes: SavePinnedCodesUseCase {
    private let repo: CountriesRepository
    public init(repo: CountriesRepository) { self.repo = repo }
    @MainActor public func execute(_ codes: [String]) throws { try repo.savePinnedCodes(codes) }
}