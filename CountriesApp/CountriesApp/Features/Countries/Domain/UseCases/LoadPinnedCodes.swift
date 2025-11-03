//
//  LoadPinnedCodes.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public final class LoadPinnedCodes: LoadPinnedCodesUseCase {
    private let repo: CountriesRepository
    public init(repo: CountriesRepository) { self.repo = repo }
    @MainActor public func execute() -> [String] { repo.loadPinnedCodes() }
}