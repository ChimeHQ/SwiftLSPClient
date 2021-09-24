//
//  Capabilities.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import AnyCodable

public struct SaveOptions: Codable {
    public let includeText: Bool?
}

public struct TextDocumentSyncOptions: Codable {
    public let openClose: Bool?
    public let change: TextDocumentSyncKind?
    public let willSave: Bool?
    public let willSaveWaitUntil: Bool?
    public let save: SaveOptions?

    public var effectiveSave: SaveOptions {
        return save ?? SaveOptions(includeText: false)
    }
}

public enum ServerCapabilitiesTextDocumentSync: Codable {
    case options(TextDocumentSyncOptions)
    case kind(TextDocumentSyncKind)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let value = try container.decode(TextDocumentSyncOptions.self)
            self = .options(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(TextDocumentSyncKind.self)
            self = .kind(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .options(let value):
            try container.encode(value)
        case .kind(let value):
            try container.encode(value)
        }
    }

    public var effectiveOptions: TextDocumentSyncOptions {
        switch self {
        case .options(let value):
            return value
        case .kind(let value):
            return TextDocumentSyncOptions(openClose: false, change: value, willSave: false, willSaveWaitUntil: false, save: nil)
        }
    }
}

public struct CompletionOptions: Codable {
    public let resolveProvider: Bool?
    public let triggerCharacters: [String]
}

public struct SignatureHelpOptions: Codable {
    public let triggerCharacters: [String]
}

public struct ExecuteCommandOptions: Codable {
    public let commands: [String]
}

public enum ServerCapabilityTypeDefinitionProvider: Codable {
    case boolean(Bool)
    case registrationOptions(TextDocumentAndStaticRegistrationOptions)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let value = try container.decode(Bool.self)
            self = .boolean(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode(TextDocumentAndStaticRegistrationOptions.self)
            self = .registrationOptions(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .boolean(let value):
            try container.encode(value)
        case .registrationOptions(let value):
            try container.encode(value)
        }
    }
}

public struct DocumentOnTypeFormattingOptions: Codable {
    public let firstTriggerCharacter: String
    public let moreTriggerCharacter: [String]?
}

public enum FileOperationPatternKind: String, Codable {
    case file = "file"
    case folder = "folder"
}

public struct FileOperationPatternOptions: Codable {
    public var ignoreCase: Bool?
}

public struct FileOperationPattern: Codable {
    public var glob: String
    public var matches: FileOperationPatternKind
    public var options: FileOperationPatternOptions
}

public struct FileOperationFilter: Codable {
    public var scheme: String?
    public var pattern: FileOperationPattern
}

public struct FileOperationRegistrationOptions: Codable {
    public var filters: [FileOperationFilter]
}

public struct WorkspaceFoldersServerCapabilities: Codable {
    public var supported: Bool?
    public var changeNotifications: TwoTypeOption<String, Bool>?
}

public struct ServerCapabilities: Codable {
    public struct Workspace: Codable {
        public struct FileOperations: Codable {
            public var didCreate: FileOperationRegistrationOptions?
            public var willCreate: FileOperationRegistrationOptions?
            public var didRename: FileOperationRegistrationOptions?
            public var willRename: FileOperationRegistrationOptions?
            public var didDelete: FileOperationRegistrationOptions?
            public var willDelete: FileOperationRegistrationOptions?
        }

        public var workspaceFolders: WorkspaceFoldersServerCapabilities?
        public var fileOperations: FileOperations?
    }

    public let textDocumentSync: ServerCapabilitiesTextDocumentSync
    public let hoverProvider: Bool?
    public let completionProvider: CompletionOptions?
    public let signatureHelpProvider: SignatureHelpOptions?
    public let definitionProvider: Bool?
    public let typeDefinitionProvider: ServerCapabilityTypeDefinitionProvider?
    public let implementationProvider: AnyCodable?
    public let referencesProvider: Bool?
    public let documentHighlightProvider: Bool?
    public let documentSymbolProvider: Bool?
    public let workspaceSymbolProvider: Bool?
    public let codeActionProvider: ServerCapabilities.CodeActionProvider?
    public let codeLensProvider: AnyCodable?
    public let documentFormattingProvider: Bool?
    public let documentRangeFormattingProvider: Bool?
    public let documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions?
    public let renameProvider: AnyCodable?
    public let semanticTokensProvider: SemanticTokensProvider?
    public let documentLinkProvider: AnyCodable?
    public let colorProvider: AnyCodable?
    public let foldingRangeProvider: AnyCodable?
    public let executeCommandProvider: AnyCodable?
    public let workspace: Workspace?
    public let experimental: AnyCodable?
}
