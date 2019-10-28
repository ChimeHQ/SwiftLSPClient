//
//  Reference.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-10-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct ReferenceContext: Codable {
    public let includeDeclaration: Bool

    public init(includeDeclaration: Bool = false) {
        self.includeDeclaration = includeDeclaration
    }
}

public struct ReferenceParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let position: Position
    public let context: ReferenceContext

    public init(textDocument: TextDocumentIdentifier, position: Position,
                context: ReferenceContext) {
        self.textDocument = textDocument
        self.position = position
        self.context = context
    }

    public init(textDocument: TextDocumentIdentifier, position: Position, includeDeclaration: Bool = false) {
        let ctx = ReferenceContext(includeDeclaration: includeDeclaration)

        self.init(textDocument: textDocument, position: position, context: ctx)
    }
}

public typealias ReferenceResponse = [Location]
