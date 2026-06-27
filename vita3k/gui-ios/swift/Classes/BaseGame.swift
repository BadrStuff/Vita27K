//
//  BaseGame.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import Foundation

class BaseGame : Codable, Equatable, Hashable, @unchecked Sendable {
    var id: UUID = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BaseGame, rhs: BaseGame) -> Bool {
        lhs.id == rhs.id
    }
}
