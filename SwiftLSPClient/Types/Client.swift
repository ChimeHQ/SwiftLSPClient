//
//  Client.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public struct TextDocumentRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
}

public struct StaticRegistrationOptions: Codable {
    public let id: String?

    public init(id: String) {
        self.id = id
    }
}

public struct TextDocumentAndStaticRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
    public let id: String?

    public init(documentSelector: DocumentSelector?, id: String?) {
        self.documentSelector = documentSelector
        self.id = id
    }
}
