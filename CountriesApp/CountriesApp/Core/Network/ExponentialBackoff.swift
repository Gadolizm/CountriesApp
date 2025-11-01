//
//  RetryPolicy.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import Foundation

protocol RetryPolicy { func delay(forAttempt attempt: Int) -> TimeInterval? }


struct ExponentialBackoff: RetryPolicy {
    let maxAttempts: Int = 3
    let baseDelay: TimeInterval = 0.3  // 300 ms

    func delay(forAttempt attempt: Int) -> TimeInterval? {
        guard attempt < maxAttempts else { return nil }
        let delay = baseDelay * pow(2.0, Double(attempt - 1))
        return min(delay, 3.0)  // cap at 3 seconds
    }
}
