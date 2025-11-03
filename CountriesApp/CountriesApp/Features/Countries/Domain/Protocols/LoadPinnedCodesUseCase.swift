//
//  LoadPinnedCodesUseCase.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//


public protocol LoadPinnedCodesUseCase { @MainActor func execute() -> [String] }