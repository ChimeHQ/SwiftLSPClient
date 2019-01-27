//
//  ClientCapabilities.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
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

public struct TextDocumentClientCapabilityPublicDiagnostics: Codable {
    public let relatedInformation: Bool?

    public init(relatedInformation: Bool) {
        self.relatedInformation = relatedInformation
    }
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
    public let publishDiagnostics: TextDocumentClientCapabilityPublicDiagnostics?
    public let foldingRange: JSONValue?

    public init(synchronization: TextDocumentClientCapabilitySynchronization?, completion: TextDocumentClientCapabilityCompletion?, hover: TextDocumentClientCapabilityHover?, publishDiagnostics: TextDocumentClientCapabilityPublicDiagnostics? = nil) {
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
        self.publishDiagnostics = publishDiagnostics
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
