//
//  SavePinnedCodesUseCase.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public protocol SavePinnedCodesUseCase { @MainActor func execute(_ codes: [String]) throws }