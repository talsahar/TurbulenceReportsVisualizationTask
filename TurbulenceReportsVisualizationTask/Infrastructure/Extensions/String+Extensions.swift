//
//  Optional + Extensions.swift
//  Turbulence Reports Visualization Task
//
//  Created by Tal Sahar on 27/11/2026.
//

import Foundation

extension Optional where Wrapped == String {

    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var orEmpty: String {
        self ?? ""
    }
}
