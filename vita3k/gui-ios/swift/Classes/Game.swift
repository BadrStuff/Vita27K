//
//  Game.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import Foundation

class Game : BaseGame, Comparable, @unchecked Sendable {
    var details: GameDetails

    init(applicationEntry: ApplicationEntry) {
        details = GameDetails(applicationEntry)
        super.init()
    }

    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    static func < (lhs: Game, rhs: Game) -> Bool {
        lhs.details.title.localizedCaseInsensitiveCompare(rhs.details.title) == .orderedAscending
    }
}
