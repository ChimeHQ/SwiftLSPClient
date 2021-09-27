import Foundation
import JSONRPC

public enum LanguageServerError: LocalizedError {
    case serverUnavailable
    case protocolError(Error)
    case invalidDocumentURI(URL)
    case unableToEncodeRequest
    case unableToDecodeResponse(Error)
    case unableToDecodeRequest(Error)
    case missingExpectedResult
    case missingExpectedParameter
    case handlerUnavailable(String)
    case operationTimedOut
    case unimplemented
    case unhandledMethod(String)
    case serverError(code: Int, message: String, data: Codable?)
    case clientError(Error)

    public init(serverError error: AnyJSONRPCResponseError) {
        self = .serverError(code: error.code,
                            message: error.message,
                            data: error.data)
    }

    public var errorDescription: String? {
        switch self {
        case .serverUnavailable:
            return "Server unavailable"
        case .protocolError(let e):
            return "Protocol error: (\(e.localizedDescription))"
        case .invalidDocumentURI(let uri):
            return "Invalid URI '\(uri)'"
        case .unableToEncodeRequest:
            return "Unable to encode request"
        case .unableToDecodeResponse(let e):
            return "Unable to decode response: \(e.localizedDescription)"
        case .missingExpectedResult:
            return "Missing expected result"
        case .operationTimedOut:
            return "Operation timed out"
        case .unimplemented:
            return "Unimplemented"
        case .serverError(code: let code, message: let message, data: let userInfo):
            return "Server error \(code), '\(message)', \(String(describing: userInfo))"
        case .missingExpectedParameter:
            return "Missing expected parameter"
        case .handlerUnavailable(let method):
            return "Handler unavailable \"\(method)\""
        case .unableToDecodeRequest(let e):
            return "Unable to decode request: \(e.localizedDescription)"
        case .unhandledMethod(let name):
            return "Unhandled method: \(name)"
        case .clientError(let e):
            return "Client error: (\(e.localizedDescription))"
        }
    }
}

public typealias LanguageServerResult<T> = Result<T, LanguageServerError>

public typealias ConfigurationHandler = (ConfigurationParams, @escaping (Result<[Encodable], Error>) -> Void) -> Void
public typealias RegistrationHandler = (RegistrationParams, @escaping (LanguageServerError?) -> Void) -> Void
public typealias UnregistrationHandler = (UnregistrationParams, @escaping (LanguageServerError?) -> Void) -> Void
public typealias SemanticTokenRefreshHandler = (@escaping (LanguageServerError?) -> Void) -> Void

public protocol LanguageServer: AnyObject {
    var notificationResponder: NotificationResponder? { get set }
    var configurationHandler: ConfigurationHandler? { get set }
    var registrationHandler: RegistrationHandler? { get set }
    var unregistrationHandler: UnregistrationHandler? { get set }
    var semanticTokenRefreshHandler: SemanticTokenRefreshHandler? { get set }

    func initialize(params: InitializeParams, block: @escaping (LanguageServerResult<InitializationResponse>) -> Void)
    func initialized(params: InitializedParams, block: @escaping (LanguageServerError?) -> Void)
    
    func didOpenTextDocument(params: DidOpenTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didChangeTextDocument(params: DidChangeTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didCloseTextDocument(params: DidCloseTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func willSaveTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func willSaveWaitUntilTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerResult<WillSaveWaitUntilResponse>) -> Void)
    func didSaveTextDocument(params: DidSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    
    func completion(params: CompletionParams, block: @escaping (LanguageServerResult<CompletionResponse>) -> Void)
    func hover(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<HoverResponse>) -> Void)
    func signatureHelp(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<SignatureHelpResponse>) -> Void)
    func declaration(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<DeclarationResponse>) -> Void)
    func definition(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<DefinitionResponse>) -> Void)
    func typeDefinition(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<TypeDefinitionResponse?>) -> Void)
    func implementation(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<ImplementationResponse>) -> Void)
    func documentSymbol(params: DocumentSymbolParams, block: @escaping (LanguageServerResult<DocumentSymbolResponse>) -> Void)
    func codeAction(params: CodeActionParams, block: @escaping (LanguageServerResult<CodeActionResponse>) -> Void)
    func prepareRename(params: PrepareRenameParams, block: @escaping (LanguageServerResult<PrepareRenameResponse?>) -> Void)
    func rename(params: RenameParams, block: @escaping (LanguageServerResult<RenameResponse>) -> Void)
    
    func formatting(params: DocumentFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func rangeFormatting(params: DocumentRangeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func onTypeFormatting(params: DocumentOnTypeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func references(params: ReferenceParams, block: @escaping (LanguageServerResult<ReferenceResponse?>) -> Void)
    func foldingRange(params: FoldingRangeParams, block: @escaping (LanguageServerResult<FoldingRangeResponse>) -> Void)

    func semanticTokensFull(params: SemanticTokensParams, block: @escaping (LanguageServerResult<SemanticTokens>) -> Void)
    func semanticTokensFullDelta(params: SemanticTokensDeltaParams, block: @escaping (LanguageServerResult<SemanticTokensDeltaResponse>) -> Void)
    func semanticTokensRange(params: SemanticTokensRangeParams, block: @escaping (LanguageServerResult<SemanticTokens>) -> Void)
}

public protocol NotificationResponder: AnyObject {
    func languageServer(_ server: LanguageServer, logMessage message: LogMessageParams)
    func languageServer(_ server: LanguageServer, showMessage message: ShowMessageParams)
    func languageServer(_ server: LanguageServer, showMessageRequest messageRequest: ShowMessageRequestParams)
    func languageServer(_ server: LanguageServer, publishDiagnostics diagnosticsParams: PublishDiagnosticsParams)

    func languageServer(_ server: LanguageServer, failedToDecodeNotification notificationName: String, with error: Error)
}
