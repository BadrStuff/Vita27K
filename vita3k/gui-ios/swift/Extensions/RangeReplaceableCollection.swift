//
//  RangeReplaceableCollection.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import Foundation

typealias AnyRangeReplaceableCollection<T> = any RangeReplaceableCollection<T>
extension RangeReplaceableCollection where Element == Game {
    mutating func appendUnique(_ element: Element) {
        if !contains(where: { game in game.details.title == element.details.title }) {
            append(element)
        }
    }
}

extension RangeReplaceableCollection where Element == String {
    mutating func appendUnique(_ element: Element) {
        if !contains(where: { letter in letter == element }) {
            append(element)
        }
    }
}
