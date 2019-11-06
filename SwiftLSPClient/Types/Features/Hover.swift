//
//  Hover.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-11-05.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum HoverContents: Codable {
    case markedString(MarkedString)
    case markedStringArray([MarkedString])
    case markupContent(MarkupContent)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(MarkedString.self) {
            self = .markedString(value)
        } else if let value = try? container.decode([MarkedString].self) {
            self = .markedStringArray(value)
        } else {
            let value = try container.decode(MarkupContent.self)
            self = .markupContent(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .markedString(let value):
            try container.encode(value)
        case .markedStringArray(let value):
            try container.encode(value)
        case .markupContent(let value):
            try container.encode(value)
        }
    }
}

extension HoverContents: Equatable {
}

public struct Hover: Codable {
    public let contents: HoverContents
    public let range: LSPRange?

    public init(contents: HoverContents, range: LSPRange? = nil) {
        self.contents = contents
        self.range = range
    }
}

extension Hover: Equatable {
}

public typealias HoverResponse = Hover?
