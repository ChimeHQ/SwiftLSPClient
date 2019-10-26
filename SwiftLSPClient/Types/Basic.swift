//
//  Types.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public typealias DocumentUri = String

public enum MarkupKind: String, Codable {
    case plaintext
    case markdown
}

public enum CompletionItemKind: Int, Codable, CaseIterable {
    case text = 1
    case method = 2
    case function = 3
    case constructor = 4
    case field = 5
    case variable = 6
    case `class` = 7
    case interface = 8
    case module = 9
    case property = 10
    case unit = 11
    case value = 12
    case `enum` = 13
    case keyword = 14
    case snippet = 15
    case color = 16
    case file = 17
    case reference = 18
    case folder = 19
    case enumMember = 20
    case constant = 21
    case `struct` = 22
    case event = 23
    case `operator` = 24
    case typeParameter = 25
}

public enum TextDocumentSyncKind: Int, Codable {
    case none = 0
    case full = 1
    case incremental = 2
}

public enum LanguageIdentifier: String, Codable, CaseIterable {
    case go = "go"
    case json = "json"
    case swift = "swift"
    case c = "c"
    case cpp = "cpp"
    case objc = "objective-c"
    case objcpp = "objective-cpp"

    static let extensions = [
        "go": .go,
        "json": .json,
        "swift": .swift,
        "c": c,
        "C": .cpp,
        "cpp": .cpp,
        "m": .objc,
        "mm": .objcpp,
        "h": .objcpp
    ]
}

public struct TextDocumentItem: Codable {
    public let uri: DocumentUri
    public let languageId: LanguageIdentifier
    public let version: Int
    public let text: String
    
    public init(uri: DocumentUri, languageId: LanguageIdentifier, version: Int, text: String) {
        self.uri = uri
        self.languageId = languageId
        self.version = version
        self.text = text
    }
}

public struct VersionedTextDocumentIdentifier: Codable {
    public let uri: DocumentUri
    public let version: Int?
    
    public init(uri: DocumentUri, version: Int?) {
        self.uri = uri
        self.version = version
    }
}

public struct TextDocumentPositionParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let position: Position
    
    public init(textDocument: TextDocumentIdentifier, position: Position) {
        self.textDocument = textDocument
        self.position = position
    }
}

public struct DocumentFilter: Codable {
    public let language: LanguageIdentifier?
    public let scheme: String?
    public let pattern: String?
}

public typealias DocumentSelector = [DocumentFilter]

public struct MarkupContent: Codable {
    public let kind: MarkupKind
    public let value: String
}

public struct TextEdit: Codable {
    public let range: LSPRange
    public let newText: String
    
    public init(range: LSPRange, newText: String) {
        self.range = range
        self.newText = newText
    }
}

public struct Command: Codable {
    public let title: String
    public let command: String
    public let arguments: [JSONValue]?
}
