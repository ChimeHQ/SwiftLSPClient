//
//  LanguageFeatures.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

// MARK: Completion
public enum CompletionTriggerKind: Int, Codable {
    case invoked = 1
    case triggerCharacter = 2
    case triggerForIncompleteCompletions = 3
}

public struct CompletionContext: Codable {
    public let triggerKind: CompletionTriggerKind
    public let triggerCharacter: String?
    
    public init(triggerKind: CompletionTriggerKind, triggerCharacter: String?) {
        self.triggerKind = triggerKind
        self.triggerCharacter = triggerCharacter
    }
}

public struct CompletionParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let position: Position
    public let context: CompletionContext?
    
    public init(textDocument: TextDocumentIdentifier, position: Position, context: CompletionContext?) {
        self.textDocument = textDocument
        self.position = position
        self.context = context
    }
    
    public init(uri: DocumentUri, position: Position, triggerKind: CompletionTriggerKind, triggerCharacter: String?) {
        let td = TextDocumentIdentifier(uri: uri)
        let ctx = CompletionContext(triggerKind: triggerKind, triggerCharacter: triggerCharacter)
        
        self.init(textDocument: td, position: position, context: ctx)
    }
}

public enum InsertTextFormat: Int, Codable {
    case plaintext = 1
    case snippet = 2
}

public struct CompletionItem: Codable {
    public let label: String
    public let kind: CompletionItemKind?
    public let detail: String?
    public let documentation: JSONValue?
    public let deprecated: Bool?
    public let preselect: Bool?
    public let sortText: String?
    public let filterText: String?
    public let insertText: String?
    public let insertTextFormat: InsertTextFormat?
    public let textEdit: TextEdit?
    public let additionalTextEdits: [TextEdit]?
    public let commitCharacters: [String]?
    public let command: Command?
    public let data: JSONValue?
}

public struct CompletionList: Codable {
    public let isIncomplete: Bool
    public let items: [CompletionItem]
    
    public init(isIncomplete: Bool, items: [CompletionItem]) {
        self.isIncomplete = isIncomplete
        self.items = items
    }
}

public enum CompletionResponse: Codable {
    case full([CompletionItem])
    case partial(CompletionList)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let value = try container.decode([CompletionItem].self)
            self = .full(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(CompletionList.self)
            self = .partial(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .full(let value):
            try container.encode(value)
        case .partial(let value):
            try container.encode(value)
        }
    }

    public var items: [CompletionItem] {
        switch self {
        case .full(let v):
            return v
        case .partial(let list):
            return list.items
        }
    }

    public var isIncomplete: Bool {
        switch self {
        case .full:
            return false
        case .partial(let value):
            return value.isIncomplete
        }
    }
}

public struct CompletionRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
    public let triggerCharacters: [String]?
    public let resolveProvider: Bool?
}

// MARK: Hover
public struct LanguageStringPair: Codable {
    public let language: LanguageIdentifier
    public let value: String
}

public enum MarkedString: Codable {
    case string(String)
    case languageString(LanguageStringPair)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let value = try container.decode(String.self)
            self = .string(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(LanguageStringPair.self)
            self = .languageString(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .languageString(let value):
            try container.encode(value)
        }
    }
    
    public var value: String {
        switch self {
        case .string(let value):
            return value
        case .languageString(let pair):
            return pair.value
        }
    }
    
    public var languageIdentifier: LanguageIdentifier? {
        switch self {
        case .languageString(let pair):
            return pair.language
        case .string(_):
            return nil
        }
    }
}

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

public struct Hover: Codable {
    public let contents: HoverContents
    public let range: LSPRange?
}
