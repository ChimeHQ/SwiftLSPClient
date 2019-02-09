//
//  DocumentSymbol.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-08.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct DocumentSymbolParams {
    public let textDocument: TextDocumentIdentifier

    public init(textDocument: TextDocumentIdentifier) {
        self.textDocument = textDocument
    }
}

extension DocumentSymbolParams: Codable {
}

extension DocumentSymbolParams: Equatable {
}

public enum DocumentSymbolResponse: Codable {
    case documentSymbols([DocumentSymbol])
    case symbolInformation([SymbolInformation])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let value = try container.decode([DocumentSymbol].self)
            self = .documentSymbols(value)
        } catch is DecodingError {
            let value = try container.decode([SymbolInformation].self)
            self = .symbolInformation(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .documentSymbols(let value):
            try container.encode(value)
        case .symbolInformation(let value):
            try container.encode(value)
        }
    }
}

extension DocumentSymbolResponse: Equatable {
}

public struct DocumentSymbol: Codable {
    public let name: String
    public let detail: String?
    public let kind: SymbolKind
    public let deprecated: Bool?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let children: [DocumentSymbol]?
}

extension DocumentSymbol: Equatable {
}

public struct SymbolInformation: Codable {
    public let name: String
    public let kind: Int
    public let deprecated: Bool?
    public let location: Location
    public let containerName: String?
}

extension SymbolInformation: Equatable {
}
