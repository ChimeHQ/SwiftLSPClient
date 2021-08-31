//
//  ClientCapabilities.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import AnyCodable

public struct GenericDynamicRegistration: Codable {
    public let dynamicRegistration: Bool?

    public init(dynamicRegistration: Bool) {
        self.dynamicRegistration = dynamicRegistration
    }
}

public enum ResourceOperationKind: String, Codable {
    case create
    case rename
    case delete
}

public enum FailureHandlingKind: String, Codable {
    case abort
    case transactional
    case textOnlyTransactional
    case undo
}

public struct WorkspaceClientCapabilityEdit: Codable {
    public let documentChanges: Bool?
    public let resourceOperations: [ResourceOperationKind]
    public let failureHandling: FailureHandlingKind?

    public init(documentChanges: Bool?, resourceOperations: [ResourceOperationKind], failureHandling: FailureHandlingKind?) {
        self.documentChanges = documentChanges
        self.resourceOperations = resourceOperations
        self.failureHandling = failureHandling
    }
}

public struct WorkspaceClientCapabilitySymbolValueSet: Codable {
    let valueSet: [SymbolKind]?

    public init(valueSet: [SymbolKind]?) {
        self.valueSet = valueSet
    }
}

public struct WorkspaceClientCapabilitySymbol: Codable {
    public let dynamicRegistration: Bool?
    public let symbolKind: WorkspaceClientCapabilitySymbolValueSet?

    public init(dynamicRegistration: Bool?, symbolKind: WorkspaceClientCapabilitySymbolValueSet?) {
        self.dynamicRegistration = dynamicRegistration
        self.symbolKind = symbolKind
    }

    public init(dynamicRegistration: Bool?, symbolKind: [SymbolKind]?) {
        self.dynamicRegistration = dynamicRegistration
        self.symbolKind = WorkspaceClientCapabilitySymbolValueSet(valueSet: symbolKind)
    }
}

public struct WorkspaceClientCapabilities: Codable {
    public let applyEdit: Bool?
    public let workspaceEdit: WorkspaceClientCapabilityEdit?
    public let didChangeConfiguration: GenericDynamicRegistration?
    public let didChangeWatchedFiles: GenericDynamicRegistration?
    public let symbol: WorkspaceClientCapabilitySymbol?
    public let executeCommand: GenericDynamicRegistration?
    public let workspaceFolders: Bool?
    public let configuration: Bool?

    public init(applyEdit: Bool, workspaceEdit: WorkspaceClientCapabilityEdit?, didChangeConfiguration: GenericDynamicRegistration?, didChangeWatchedFiles: GenericDynamicRegistration?, symbol: WorkspaceClientCapabilitySymbol?, executeCommand: GenericDynamicRegistration?, workspaceFolders: Bool?, configuration: Bool?) {
        self.applyEdit = applyEdit
        self.workspaceEdit = workspaceEdit
        self.didChangeConfiguration = didChangeConfiguration
        self.didChangeWatchedFiles = didChangeWatchedFiles
        self.symbol = symbol
        self.executeCommand = executeCommand
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

public struct TextDocumentClientCapabilityPublicDiagnostics: Codable {
    public struct TagSupport: Codable, Equatable {
        let valueSet: [DiagnosticTag]
    }

    public let relatedInformation: Bool?
    public let tagSupport: TagSupport?
    public let versionSupport: Bool?

    public init(relatedInformation: Bool, versionSupport: Bool? = false, supportedTags: [DiagnosticTag]? = nil) {
        self.relatedInformation = relatedInformation
        self.versionSupport = versionSupport
        self.tagSupport = supportedTags.map { TagSupport(valueSet: $0) }
    }
}

public struct TextDocumentClientCapabilityFoldingRange: Codable {
    public let dynamicRegistration: Bool?
    public let rangeLimit: Int?
    public let lineFoldingOnly: Bool?

    public init(dynamicRegistration: Bool?, rangeLimit: Int?, lineFoldingOnly: Bool?) {
        self.dynamicRegistration = dynamicRegistration
        self.rangeLimit = rangeLimit
        self.lineFoldingOnly = lineFoldingOnly
    }
}

public struct TextDocumentClientCapabilities: Codable {
    public let synchronization: TextDocumentClientCapabilitySynchronization?
    public let completion: TextDocumentClientCapabilityCompletion?
    public let hover: TextDocumentClientCapabilityHover?
    public let signatureHelp: TextDocumentClientCapabilities.SignatureHelp?
    public let references: GenericDynamicRegistration?
    public let documentHighlight: AnyCodable?
    public let documentSymbol: AnyCodable?
    public let formatting: GenericDynamicRegistration?
    public let rangeFormatting: GenericDynamicRegistration?
    public let onTypeFormatting: GenericDynamicRegistration?
    public let declaration: TextDocumentClientCapabilitiesGenericGoTo?
    public let definition: TextDocumentClientCapabilitiesGenericGoTo?
    public let typeDefinition: TextDocumentClientCapabilitiesGenericGoTo?
    public let implementation: TextDocumentClientCapabilitiesGenericGoTo?
    public let codeAction: CodeActionClientCapabilities?
    public let codeLens: AnyCodable?
    public let documentLink: AnyCodable?
    public let colorProvider: AnyCodable?
    public let rename: RenameClientCapabilites?
    public let publishDiagnostics: TextDocumentClientCapabilityPublicDiagnostics?
    public let foldingRange: TextDocumentClientCapabilityFoldingRange?

    public init(synchronization: TextDocumentClientCapabilitySynchronization?, completion: TextDocumentClientCapabilityCompletion?, hover: TextDocumentClientCapabilityHover?, signatureHelp: TextDocumentClientCapabilities.SignatureHelp? = nil, references: GenericDynamicRegistration? = nil, formatting: GenericDynamicRegistration?, rangeFormatting: GenericDynamicRegistration?, onTypeFormatting: GenericDynamicRegistration?, declaration: TextDocumentClientCapabilitiesGenericGoTo? = nil, definition: TextDocumentClientCapabilitiesGenericGoTo? = nil, typeDefinition: TextDocumentClientCapabilitiesGenericGoTo? = nil, implemenation: TextDocumentClientCapabilitiesGenericGoTo? = nil, codeAction: CodeActionClientCapabilities? = nil, publishDiagnostics: TextDocumentClientCapabilityPublicDiagnostics?,
                foldingRange: TextDocumentClientCapabilityFoldingRange? = nil) {
        self.synchronization = synchronization
        self.completion = completion
        self.hover = hover
        self.signatureHelp = signatureHelp
        self.references = references
        self.documentHighlight = nil
        self.documentSymbol = nil
        self.formatting = formatting
        self.rangeFormatting = rangeFormatting
        self.onTypeFormatting = onTypeFormatting
        self.declaration = declaration
        self.definition = definition
        self.typeDefinition = typeDefinition
        self.implementation = implemenation
        self.codeAction = codeAction
        self.codeLens = nil
        self.documentLink = nil
        self.colorProvider = nil
        self.rename = nil
        self.publishDiagnostics = publishDiagnostics
        self.foldingRange = nil
    }
}

public struct ClientCapabilities: Codable {
    public let workspace: WorkspaceClientCapabilities?
    public let textDocument: TextDocumentClientCapabilities?
    public let experimental: AnyCodable?

    public init(workspace: WorkspaceClientCapabilities?, textDocument: TextDocumentClientCapabilities?, experimental: AnyCodable?) {
        self.workspace = workspace
        self.textDocument = textDocument
        self.experimental = experimental
    }
}
