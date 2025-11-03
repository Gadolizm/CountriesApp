//
//  PinnedSD.swift
//  CountriesApp
//
//  Created by Haitham Gado on 03/11/2025.
//

import SwiftData

@Model
final class PinnedSD {
    @Attribute(.unique) var alpha2Code: String
    var order: Int      // to keep user order (0..4)

    init(alpha2Code: String, order: Int) {
        self.alpha2Code = alpha2Code
        self.order = order
    }
}
