//
//  SavePinnedCodesUseCaseSpy.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp

final class SavePinnedCodesUseCaseSpy: SavePinnedCodesUseCase {
    private(set) var saved: [[String]] = []
    func execute(_ codes: [String]) throws { saved.append(codes) }
}
