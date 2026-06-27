//
//  Sequence.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import Foundation

extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
