//
//  WillSaveTextDocument.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-10.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum TextDocumentSaveReason: Int {
    case manual = 1
    case afterDelay = 2
    case focusOut = 3
}

extension TextDocumentSaveReason: Codable {
}

extension TextDocumentSaveReason: Equatable {
}

public struct WillSaveTextDocumentParams {
    public let textDocument: TextDocumentIdentifier
    public let reason: TextDocumentSaveReason

    public init(textDocument: TextDocumentIdentifier, reason: TextDocumentSaveReason) {
        self.textDocument = textDocument
        self.reason = reason
    }
}

extension WillSaveTextDocumentParams: Codable {
}

extension WillSaveTextDocumentParams: Equatable {
}

public typealias WillSaveWaitUntilResponse = [TextEdit]?
