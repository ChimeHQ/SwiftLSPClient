//
//  JSONValue.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum JSONValue: Codable {
    case null
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String : JSONValue])
    case array([JSONValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String : JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            let ctx = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown JSON Type")
            throw DecodingError.typeMismatch(JSONValue.self, ctx)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .null:
            try container.encodeNil()
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}

extension JSONValue: Equatable {
}
