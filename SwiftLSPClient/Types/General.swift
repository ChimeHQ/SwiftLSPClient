//
//  General.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Matt Massicotte. All rights reserved.
//

import Foundation

public struct WorkspaceClientCapabilities: Codable {
    public let applyEdit: Bool?
//    public let workspaceEdit: JSONValue?
//    public let didChangeConfiguration: JSONValue?
//    public let didChangeWatchedFiles: JSONValue?
//    public let symbol: JSONValue?
//    public let executeCommand: JSONValue?
    public let workspaceFolders: Bool?
    public let configuration: Bool?
    
    public init(applyEdit: Bool, workspaceFolders: Bool, configuration: Bool) {
        self.applyEdit = applyEdit
        self.workspaceFolders = workspaceFolders
        self.configuration = configuration
    }
}

public struct TextDocumentClientCapabilitySynchronization: Codable {
    public let dynamicRegistration: Bool?
    public let willSave: Bool?
    public let willSaveWaitUntil: Bool?
    public let didSave: Bool?
    
    public init(dynamicRegistration: Bool, willSave: Bool, willSaveWaitUntil: Bool, didSave: Bool) {
        self.dynamicRegistration = dynamicRegistration
        self.willSave = willSave
        self.willSaveWaitUntil = willSaveWaitUntil
        self.didSave = didSave
    }
}

public struct TextDocumentClientCapabilityCompletionItem: Codable {
    public let snippetSupport: Bool?
    public let commitCharactersSupport: Bool?
    public let documentationFormat: [MarkupKind]?
    public let deprecatedSupport: Bool?
    public let preselectSupport: Bool?
    
    public init(snippetSupport: Bool, commitCharactersSupport: Bool, documentationFormat: [MarkupKind], deprecatedSupport: Bool, preselectSupport: Bool) {
        self.snippetSupport = snippetSupport
        self.commitCharactersSupport = commitCharactersSupport
        self.documentationFormat = documentationFormat
        self.deprecatedSupport = deprecatedSupport
        self.preselectSupport = preselectSupport
    }
}

public struct TextDocumentClientCapabilityCompletionItemKind: Codable {
    public let valueSet: [CompletionItemKind]?
    
    public init(valueSet: [CompletionItemKind]?) {
        self.valueSet = valueSet
    }

    public static var all: TextDocumentClientCapabilityCompletionItemKind {
        return TextDocumentClientCapabilityCompletionItemKind(valueSet: CompletionItemKind.allCases)
    }
}

public struct TextDocumentClientCapabilityCompletion: Codable {
    public let dynamicRegistration: Bool?
    public let completionItem: TextDocumentClientCapabilityCompletionItem?
    public let completionItemKind: TextDocumentClientCapabilityCompletionItemKind?
    
    public init(dynamicRegistration: Bool?, completionItem: TextDocumentClientCapabilityCompletionItem?, completionItemKind: TextDocumentClientCapabilityCompletionItemKind?) {
        self.dynamicRegistration = dynamicRegistration
        self.completionItem = completionItem
        self.completionItemKind = completionItemKind
    }
}

public struct TextDocumentClientCapabilityHover: Codable {
    public let dynamicRegistration: Bool?
    public let contentFormat: [MarkupKind]?
    
    public init(dynamicRegistration: Bool?, contentFormat: [MarkupKind]?) {
        self.dynamicRegistration = dynamicRegistration
        self.contentFormat = contentFormat
    }
}

public struct TextDocumentClientCapability: Codable {
    public let dynamicRegistration: Bool?
    public let contentFormat: [MarkupKind]?
}

public struct TextDocumentClientCapabilities: Codable {
    public let synchronization: TextDocumentClientCapabilitySynchronization?
    public let completion: TextDocumentClientCapabilityCompletion?
    public let hover: TextDocumentClientCapabilityHover?
    public let signatureHelp: JSONValue?
    public let references: JSONValue?
    public let documentHighlight: JSONValue?
    public let documentSymbol: JSONValue?
    public let formatting: JSONValue?
    public let rangeFormatting: JSONValue?
    public let onTypeFormatting: JSONValue?
    public let definition: JSONValue?
    public let typeDefinition: JSONValue?
    public let implementation: JSONValue?
    public let codeAction: JSONValue?
    public let codeLens: JSONValue?
    public let documentLink: JSONValue?
    public let colorProvider: JSONValue?
    public let rename: JSONValue?
    public let publishDiagnostics: JSONValue?
    public let foldingRange: JSONValue?
    
    public init(synchronization: TextDocumentClientCapabilitySynchronization?, completion: TextDocumentClientCapabilityCompletion?, hover: TextDocumentClientCapabilityHover?) {
        self.synchronization = synchronization
        self.completion = completion
        self.hover = hover
        self.signatureHelp = nil
        self.references = nil
        self.documentHighlight = nil
        self.documentSymbol = nil
        self.formatting = nil
        self.rangeFormatting = nil
        self.onTypeFormatting = nil
        self.definition = nil
        self.typeDefinition = nil
        self.implementation = nil
        self.codeAction = nil
        self.codeLens = nil
        self.documentLink = nil
        self.colorProvider = nil
        self.rename = nil
        self.publishDiagnostics = nil
        self.foldingRange = nil
    }
}

public struct ClientCapabilities: Codable {
    public let workspace: WorkspaceClientCapabilities?
    public let textDocument: TextDocumentClientCapabilities?
    public let experimental: JSONValue?
    
    public init(workspace: WorkspaceClientCapabilities?, textDocument: TextDocumentClientCapabilities?, experimental: JSONValue?) {
        self.workspace = workspace
        self.textDocument = textDocument
        self.experimental = experimental
    }
}

public enum Tracing: String, Codable {
    case off
    case messages
    case verbose
}

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

public struct InitalizeParams: Codable {
    public let processId: Int
    public let rootPath: String?
    public let rootURI: DocumentUri?
    public let initializationOptions: JSONValue?
    public let capabilities: ClientCapabilities
    public let trace: Tracing?
    public let workspaceFolders: [WorkspaceFolder]?
    
    public init(processId: Int, rootPath: String?, rootURI: DocumentUri?, initializationOptions: JSONValue?, capabilities: ClientCapabilities, trace: Tracing?, workspaceFolders: [WorkspaceFolder]?) {
        self.processId = processId
        self.rootPath = rootPath
        self.rootURI = rootURI
        self.initializationOptions = initializationOptions
        self.capabilities = capabilities
        self.trace = trace
        self.workspaceFolders = workspaceFolders
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

public struct ServerCapabilities: Codable {
    public let textDocumentSync: ServerCapabilitiesTextDocumentSync
    public let hoverProvider: Bool?
    public let completionProvider: CompletionOptions?
    public let signatureHelpProvider: SignatureHelpOptions?
    public let definitionProvider: Bool?
    public let typeDefinitionProvider: JSONValue?
    public let implementationProvider: JSONValue?
    public let referencesProvider: Bool?
    public let documentHighlightProvider: Bool?
    public let documentSymbolProvider: Bool?
    public let workspaceSymbolProvider: Bool?
    public let codeActionProvider: JSONValue?
    public let codeLensProvider: JSONValue?
    public let documentFormattingProvider: Bool?
    public let documentRangeFormattingProvider: Bool?
    public let documentOnTypeFormattingProvider: JSONValue?
    public let renameProvider: JSONValue?
    public let documentLinkProvider: JSONValue?
    public let colorProvider: JSONValue?
    public let foldingRangeProvider: JSONValue?
    public let executeCommandProvider: JSONValue?
    public let workspace: JSONValue?
    public let experimental: JSONValue?
}

public struct InitializationResponse: Codable {
    public let capabilities: ServerCapabilities
}
