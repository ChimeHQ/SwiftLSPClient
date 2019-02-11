//
//  TextSynchronization.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public struct DidOpenTextDocumentParams: Codable {
    public let textDocument: TextDocumentItem
    
    public init(textDocument: TextDocumentItem) {
        self.textDocument = textDocument
    }
}

public struct TextDocumentContentChangeEvent: Codable {
    public let range: LSPRange?
    public let rangeLength: Int?
    public let text: String
    
    public init(range: LSPRange?, rangeLength: Int?, text: String) {
        self.range = range
        self.rangeLength = rangeLength
        self.text = text
    }
}

public struct DidChangeTextDocumentParams: Codable {
    public let textDocument: VersionedTextDocumentIdentifier
    public let contentChanges: [TextDocumentContentChangeEvent]
    
    public init(textDocument: VersionedTextDocumentIdentifier, contentChanges: [TextDocumentContentChangeEvent]) {
        self.textDocument = textDocument
        self.contentChanges = contentChanges
    }
    
    public init(uri: DocumentUri, version: Int, contentChanges: [TextDocumentContentChangeEvent]) {
        self.textDocument = VersionedTextDocumentIdentifier(uri: uri, version: version)
        self.contentChanges = contentChanges
    }
    
    public init(uri: DocumentUri, version: Int, contentChange: TextDocumentContentChangeEvent) {
        self.textDocument = VersionedTextDocumentIdentifier(uri: uri, version: version)
        self.contentChanges = [contentChange]
    }
}

public struct TextDocumentChangeRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
    public let syncKind: TextDocumentSyncKind
}

public struct DidSaveTextDocumentParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let text: String?
    
    public init(textDocument: TextDocumentIdentifier, text: String? = nil) {
        self.textDocument = textDocument
        self.text = text
    }
    
    public init(uri: DocumentUri, text: String? = nil) {
        let docId = TextDocumentIdentifier(uri: uri)
        
        self.textDocument = docId
        self.text = text
    }
}

public struct TextDocumentSaveRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
    public let includeText: Bool?
}

public struct DidCloseTextDocumentParams: Codable {
    public let textDocument: TextDocumentIdentifier
    
    public init(textDocument: TextDocumentIdentifier) {
        self.textDocument = textDocument
    }
    
    public init(uri: DocumentUri) {
        let docId = TextDocumentIdentifier(uri: uri)
        
        self.init(textDocument: docId)
    }
}
