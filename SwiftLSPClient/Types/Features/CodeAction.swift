//
//  SignatureHelp.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-12-07.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public typealias CodeActionKind = String

extension CodeActionKind {
    public static var Empty: CodeActionKind = ""
    public static var Quickfix: CodeActionKind = "quickfix"
    public static var Refactor: CodeActionKind = "refactor"
    public static var RefactorExtract: CodeActionKind = "refactor.extract"
    public static var RefactorInline: CodeActionKind = "refactor.inline"
    public static var RefactorRewrite: CodeActionKind = "refactor.rewrite"
    public static var Source: CodeActionKind = "source"
    public static var SourceOrganizeImports: CodeActionKind = "source.organizeImports"
}

public extension ServerCapabilities {
    enum CodeActionProvider: Codable {
        case boolean(Bool)
        case options(CodeActionOptions)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            do {
                let value = try container.decode(Bool.self)
                self = .boolean(value)
            } catch DecodingError.typeMismatch {
                let value = try container.decode(CodeActionOptions.self)
                self = .options(value)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .boolean(let value):
                try container.encode(value)
            case .options(let value):
                try container.encode(value)
            }
        }
    }

    struct CodeActionOptions: Codable {
        public let codeActionKinds: [CodeActionKind]?
    }
}

public struct CodeActionClientCapabilities: Codable {
    public struct LiteralSupport: Codable {
        public struct ValueSet: Codable {
            let valueSet: [CodeActionKind]
        }

        let codeActionKind: ValueSet
    }

    public let dynamicRegistration: Bool?
    public let codeActionLiteralSupport: LiteralSupport?
    public let isPreferredSupport: Bool?

    public init(dynamicRegistration: Bool?, valueSet: [CodeActionKind], isPreferredSupport: Bool?) {
        self.dynamicRegistration = dynamicRegistration
        self.codeActionLiteralSupport = LiteralSupport(codeActionKind: LiteralSupport.ValueSet(valueSet: valueSet))
        self.isPreferredSupport = isPreferredSupport
    }
}

public struct CodeActionContext: Codable {
    public let diagnostics: [Diagnostic]
    public let only: [CodeActionKind]?

    public init(diagnostics: [Diagnostic] = [], only: [CodeActionKind]? = nil) {
        self.diagnostics = diagnostics
        self.only = only
    }
}

public struct CodeActionParams: Codable {
    public let textDocument: TextDocumentIdentifier
    public let range: LSPRange
    public let context: CodeActionContext

    public init(textDocument: TextDocumentIdentifier, range: LSPRange, context: CodeActionContext) {
        self.textDocument = textDocument
        self.range = range
        self.context = context
    }
}

public struct CodeAction: Codable, Equatable {
    public let title: String
    public let kind: CodeActionKind?
    public let diagnostics: [Diagnostic]?
    public let isPreferred: Bool?
    public let edit: WorkspaceEdit?
    public let command: Command?
}

public enum CodeActionResponseType: Codable {
    case commands([Command])
    case actions([CodeAction])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let value = try container.decode([CodeAction].self)
            self = .actions(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode([Command].self)
            self = .commands(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .commands(let value):
            try container.encode(value)
        case .actions(let value):
            try container.encode(value)
        }
    }
}

extension CodeActionResponseType: Equatable {
}

public typealias CodeActionResponse = CodeActionResponseType?
