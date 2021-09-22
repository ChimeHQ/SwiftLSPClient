import Foundation
import AnyCodable

public struct SemanticTokensWorkspaceClientCapabilities: Codable {
//    public var refreshSupport: Bool?
//
//    public init(refreshSupport: Bool) {
//        self.refreshSupport = refreshSupport
//    }

    public init() {
    }
}

public enum TokenFormat: String, Codable {
    case relative = "relative"

    public static let Relative = TokenFormat.relative
}

public struct SemanticTokensClientCapabilities: Codable {
    public struct Requests: Codable {
        public struct Range: Codable {
        }

        public struct Full: Codable {
            public var delta: Bool?

            public init(delta: Bool = true) {
                self.delta = delta
            }
        }

        public typealias RangeOption = TwoTypeOption<Bool, Range>
        public typealias FullOption = TwoTypeOption<Bool, Full>

        public var range: RangeOption
        public var full: FullOption

        public init(range: Bool = true, delta: Bool = true) {
            self.range = .optionA(range)
            self.full = .optionB(Full(delta: true))
        }
    }

    public var dynamicRegistration: Bool?
//    public var requests: Requests
    public var tokenTypes: [String]
    public var tokenModifiers: [String]
    public var formats: [TokenFormat]
    public var overlappingTokenSupport: Bool?
//    public var multilineTokenSupport: Bool?

    public init(dynamicRegistration: Bool = false,
                requests: SemanticTokensClientCapabilities.Requests = .init(range: true, delta: true),
                tokenTypes: [String] = SemanticTokenTypes.allStrings,
                tokenModifiers: [String] = SemanticTokenModifiers.allStrings,
                formats: [TokenFormat] = [TokenFormat.relative],
                overlappingTokenSupport: Bool = true,
                multilineTokenSupport: Bool = true) {
        self.dynamicRegistration = dynamicRegistration
//        self.requests = requests
        self.tokenTypes = tokenTypes
        self.tokenModifiers = tokenModifiers
        self.formats = formats
        self.overlappingTokenSupport = overlappingTokenSupport
//        self.multilineTokenSupport = multilineTokenSupport
    }
}

public struct SemanticTokensLegend: Codable {
    public var tokenTypes: [String]
    public var tokenModifiers: [String]
}

public struct SemanticTokensOptions: Codable {
    public var workDoneProgress: Bool?
    public var legend: SemanticTokensLegend
    public var range: SemanticTokensClientCapabilities.Requests.RangeOption
    public var full: SemanticTokensClientCapabilities.Requests.FullOption
}

public struct SemanticTokensRegistrationOptions: Codable {
    public var documentSelector: DocumentSelector?
    public var workDoneProgress: Bool?
    public var legend: SemanticTokensLegend
    public var range: SemanticTokensClientCapabilities.Requests.RangeOption
    public var full: SemanticTokensClientCapabilities.Requests.FullOption
    public var id: String?
}

extension ServerCapabilities {
    public typealias SemanticTokensProvider = TwoTypeOption<SemanticTokensOptions, SemanticTokensRegistrationOptions>
}

public enum SemanticTokenTypes: String, Codable, Hashable, CaseIterable {
    case namespace = "namespace"
    case type = "type"
    case `class` = "class"
    case `enum` = "enum"
    case interface = "interface"
    case `struct` = "struct"
    case typeParameter = "typeParameter"
    case parameter = "parameter"
    case variable = "variable"
    case property = "property"
    case enumMember = "enumMember"
    case event = "event"
    case function = "function"
    case method = "method"
    case macro = "macro"
    case keyword = "keyword"
    case modifier = "modifier"
    case comment = "comment"
    case string = "string"
    case number = "number"
    case regexp = "regexp"
    case `operator` = "operator"

    public static var allStrings: [String] {
        return allCases.map({ $0.rawValue })
    }
}

public enum SemanticTokenModifiers: String, Codable, Hashable, CaseIterable {
    case declaration = "declaration"
    case definition = "definition"
    case readonly = "readonly"
    case `static` = "static"
    case deprecated = "deprecated"
    case abstract = "abstract"
    case async = "async"
    case modification = "modification"
    case documentation = "documentation"
    case defaultLibrary = "defaultLibrary"

    public static var allStrings: [String] {
        return allCases.map({ $0.rawValue })
    }
}

public struct SemanticTokensParams: Codable {
    public var workDoneToken: ProgressToken?
    public var partialResultToken: ProgressToken?
    public var textDocument: TextDocumentIdentifier

    public init(textDocument: TextDocumentIdentifier) {
        self.textDocument = textDocument
    }
}

public struct SemanticTokens: Codable {
    public var resultId: String?
    public var data: [UInt]
}

public struct SemanticTokensPartialResult: Codable {
    public var data: [UInt]
}

public struct SemanticTokensDeltaParams: Codable {
    public var workDoneToken: ProgressToken?
    public var partialResultToken: ProgressToken?
    public var textDocument: TextDocumentIdentifier
    public var previousResultId: String

    public init(textDocument: TextDocumentIdentifier, previousResultId: String) {
        self.textDocument = textDocument
        self.previousResultId = previousResultId
    }
}

public struct SemanticTokensEdit: Codable {
    public var start: UInt
    public var deleteCount: UInt
    public var data: [UInt]?
}

public struct SemanticTokensDelta: Codable {
    public var resultId: String?
    public var edits: [SemanticTokensEdit]
}

public typealias SemanticTokensDeltaResponse = TwoTypeOption<SemanticTokens, SemanticTokensDelta>

public struct SemanticTokensRangeParams: Codable {
    public var workDoneToken: ProgressToken?
    public var partialResultToken: ProgressToken?
    public var textDocument: TextDocumentIdentifier
    public var range: LSPRange

    public init(textDocument: TextDocumentIdentifier, range: LSPRange) {
        self.textDocument = textDocument
        self.range = range
    }
}
