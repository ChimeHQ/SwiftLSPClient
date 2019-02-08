//
//  TextDocumentIndentifier.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct TextDocumentIdentifier {
    public let uri: DocumentUri

    public init(uri: DocumentUri) {
        self.uri = uri
    }
}

extension TextDocumentIdentifier: Codable {
}

extension TextDocumentIdentifier: Equatable {
}

extension TextDocumentIdentifier: CustomStringConvertible {
    public var description: String {
        return uri.description
    }
}
