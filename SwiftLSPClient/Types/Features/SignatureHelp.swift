//
//  SignatureHelp.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-12-07.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public extension TextDocumentClientCapabilities {
    struct SignatureHelp: Codable {
        public struct SignatureInformation: Codable {
            public struct ParameterInformation: Codable {
                public let labelOffsetSupport: Bool?

                public init(labelOffsetSupport: Bool?) {
                    self.labelOffsetSupport = labelOffsetSupport
                }
            }

            public let documentationFormat: [MarkupKind]?
            public let parameterInformation: ParameterInformation?

            public init(documentationFormat: [MarkupKind]?, parameterInformation: ParameterInformation?) {
                self.documentationFormat = documentationFormat
                self.parameterInformation = parameterInformation
            }

            public init(documentationFormat: [MarkupKind]?, labelOffsetSupport: Bool?) {
                let paramInfo = ParameterInformation(labelOffsetSupport: labelOffsetSupport)

                self.init(documentationFormat: documentationFormat, parameterInformation: paramInfo)
            }
        }

        public let dynamicRegistration: Bool?
        public let signatureInformation: SignatureHelp.SignatureInformation?

        public init(dynamicRegistration: Bool?, documentationFormat: [MarkupKind]?, labelOffsetSupport: Bool?) {
            self.dynamicRegistration = dynamicRegistration
            self.signatureInformation = SignatureHelp.SignatureInformation(documentationFormat: documentationFormat, labelOffsetSupport: labelOffsetSupport)
        }
    }
}

public enum SignatureHelpDocumentation: Codable {
    case string(String)
    case markup(MarkupContent)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            let value = try container.decode(MarkupContent.self)
            self = .markup(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .markup(let value):
            try container.encode(value)
        }
    }
}

public struct ParameterInformation: Codable {
    let label: String
    let documentation: SignatureHelpDocumentation
}

public struct SignatureInformation: Codable {
    let label: String
    let documentation: SignatureHelpDocumentation
    let parameters: [ParameterInformation]
}

public struct SignatureHelp: Codable {
    public let signatures: [SignatureInformation]
    public let activeSignature: Int?
    public let activeParameter: Int?
}

public struct SignatureHelpRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
    public let triggerCharacters: [String]?
}

public typealias SignatureHelpResponse = SignatureHelp?
