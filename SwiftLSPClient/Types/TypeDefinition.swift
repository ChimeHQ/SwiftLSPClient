//
//  TypeDefinition.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-13.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum TypeDefinitionResponse {
    case location(Location)
    case locationArray([Location])
    case locationLinkArray([LocationLink])
}

extension TypeDefinitionResponse: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Location.self) {
            self = .location(value)
        } else if let value = try? container.decode([Location].self) {
            self = .locationArray(value)
        } else {
            let value = try container.decode([LocationLink].self)
            self = .locationLinkArray(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .location(let value):
            try container.encode(value)
        case .locationArray(let value):
            try container.encode(value)
        case .locationLinkArray(let value):
            try container.encode(value)
        }
    }
}
