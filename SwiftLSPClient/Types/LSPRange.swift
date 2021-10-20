//
//  LSPRange.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-16.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct LSPRange {
    public let start: Position
    public let end: Position

    public init(start: Position, end: Position) {
        self.start = start
        self.end = end
    }

    public init(startPair: (Int, Int), endPair: (Int, Int)) {
        self.start = Position(startPair)
        self.end = Position(endPair)
    }

    public func contains(_ position: Position) -> Bool {
        return position > start && position < end
    }

    public func intersects(_ other: LSPRange) -> Bool {
        return contains(other.start) || contains(other.end)
    }
}

extension LSPRange: CustomStringConvertible {
    public var description: String {
        return "(\(start), \(end))"
    }
}

extension LSPRange: Codable {
}

extension LSPRange: Hashable {
}

public extension LSPRange {
    static let zero = LSPRange(start: .zero, end: .zero)
}
