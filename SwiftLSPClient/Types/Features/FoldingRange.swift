//
//  FoldingRange.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-11-02.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct FoldingRangeParams: Codable {
    public let textDocument: TextDocumentIdentifier

    public init(textDocument: TextDocumentIdentifier) {
        self.textDocument = textDocument
    }
}

public enum FoldingRangeKind: String {
    case comment
    case imports
    case region
}

extension FoldingRangeKind: Codable {
}

public struct FoldingRange: Codable {
    public let startLine: Int
    public let startCharacter: Int?
    public let endLine: Int
    public let endCharacter: Int?
    public let kind: FoldingRangeKind?
}

public typealias FoldingRangeResponse = [FoldingRange]?
