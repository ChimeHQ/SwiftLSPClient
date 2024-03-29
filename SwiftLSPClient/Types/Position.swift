//
//  Position.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-16.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct Position {
    public let line: Int
    public let character: Int

    public init(line: Int, character: Int) {
        self.line = line
        self.character = character
    }

    public init(_ pair: (Int, Int)) {
        self.line = pair.0
        self.character = pair.1
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        return "{\(line), \(character)}"
    }
}

extension Position: Codable {
}

extension Position: Hashable {
}

extension Position: Comparable {
    public static func < (lhs: Position, rhs: Position) -> Bool {
        if lhs.line == rhs.line {
            return lhs.character < rhs.character
        }

        return lhs.line < rhs.line
    }
}

public extension Position {
    static let zero = Position(line: 0, character: 0)
}
