//
//  File.swift
//  
//
//  Created by ?? on 2021-08-22.
//

import Foundation

public typealias PrepareRenameParams = TextDocumentPositionParams

public struct RenameParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let position: Position
    public let newName: String
    
    public init(textDocument: TextDocumentIdentifier, position: Position,
                newName: String) {
        self.textDocument = textDocument
        self.position = position
        self.newName = newName
    }
}

public enum PrepareRenameResponse: Codable {
    case range(LSPRange)
    case rangeWithPlaceholder(range: LSPRange, placeholder: String)
    case defaultBehaviour(Bool)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(LSPRange.self) {
            self = .range(value)
        } else if let value = try? container.decode(RangeWithPlaceholder.self) {
            self = .rangeWithPlaceholder(range: value.range, placeholder: value.placeholder)
        } else {
            let value = try container.decode(PrepareRenameDefaultBehaviour.self)
            self = .defaultBehaviour(value.defaultBehaviour)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .range(range):
            try container.encode(range)
        case let .rangeWithPlaceholder(range, placeholder):
            try container.encode(RangeWithPlaceholder(range: range, placeholder: placeholder))
        case let .defaultBehaviour(value):
            try container.encode(PrepareRenameDefaultBehaviour(defaultBehaviour: value))
        }
    }
}

struct RangeWithPlaceholder: Codable {
    let range: LSPRange
    let placeholder: String
}

struct PrepareRenameDefaultBehaviour: Codable {
    let defaultBehaviour: Bool
}

public typealias RenameResponse = WorkspaceEdit?

public struct RenameClientCapabilites: Codable {
    public enum PrepareSupportDefaultBehaviour: Int, Codable {
        case identifier = 1
    }
    
    public let dynamicRegistration: Bool?
    public let prepareSupport: Bool?
    public let prepareSupportBehaviour: PrepareSupportDefaultBehaviour?
    public let honorsChangeAnnotations: Bool?
    
    public init(dynamicRegistration: Bool?, prepareSupport: Bool?, prepareSupportBehaviour: RenameClientCapabilites.PrepareSupportDefaultBehaviour?, honorsChangeAnnotations: Bool?) {
        self.dynamicRegistration = dynamicRegistration
        self.prepareSupport = prepareSupport
        self.prepareSupportBehaviour = prepareSupportBehaviour
        self.honorsChangeAnnotations = honorsChangeAnnotations
    }
    
}

public struct RenameOptions: Codable {
    public let prepareProvider: Bool?
}
