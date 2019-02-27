//
//  Formatting.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-26.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct FormattingOptions: Codable {
    public let tabSize: Int
    public let insertSpaces: Bool

    public init(tabSize: Int, insertSpaces: Bool) {
        self.tabSize = tabSize
        self.insertSpaces = insertSpaces
    }
}

public struct DocumentFormattingParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let options: FormattingOptions

    public init(textDocument: TextDocumentIdentifier, options: FormattingOptions) {
        self.textDocument = textDocument
        self.options = options
    }
}

public struct DocumentRangeFormattingParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let range: LSPRange
    public let options: FormattingOptions

    public init(textDocument: TextDocumentIdentifier, range: LSPRange, options: FormattingOptions) {
        self.textDocument = textDocument
        self.range = range
        self.options = options
    }
}

public struct DocumentOnTypeFormattingParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let position: Position
    public let ch: String
    public let options: FormattingOptions

    public init(textDocument: TextDocumentIdentifier, position: Position, ch: String, options: FormattingOptions) {
        self.textDocument = textDocument
        self.position = position
        self.ch = ch
        self.options = options
    }
}

public typealias FormattingResult = [TextEdit]?
