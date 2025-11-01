//
//  CountriesRepository.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


protocol CountriesRepository { func fetchAll() async throws -> [Country] }
