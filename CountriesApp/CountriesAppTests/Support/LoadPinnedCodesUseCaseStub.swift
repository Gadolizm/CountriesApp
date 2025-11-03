//
//  LoadPinnedCodesUseCaseStub.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import XCTest
@testable import CountriesApp

struct LoadPinnedCodesUseCaseStub: LoadPinnedCodesUseCase {
    let codes: [String]
    func execute() -> [String] { codes }
}
