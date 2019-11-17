//
//  LanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public enum LanguageServerError: LocalizedError {
    case serverUnavailable
    case protocolError(Error)
    case invalidDocumentURI(URL)
    case unableToEncodeRequest
    case unableToDecodeResponse(Error)
    case missingExpectedResult
    case operationTimedOut
    case unimplemented
    
    case serverError(code: Int, message: String, data: [String : AnyObject]?)

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
        }
    }
}

public typealias LanguageServerResult<T> = Result<T, LanguageServerError>

public protocol LanguageServer: class {
    var notificationResponder: NotificationResponder? { get set }

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

    func formatting(params: DocumentFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func rangeFormatting(params: DocumentRangeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func onTypeFormatting(params: DocumentOnTypeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func references(params: ReferenceParams, block: @escaping (LanguageServerResult<ReferenceResponse?>) -> Void)
    func foldingRange(params: FoldingRangeParams, block: @escaping (LanguageServerResult<FoldingRangeResponse>) -> Void)
}

public protocol NotificationResponder: class {
    func languageServer(_ server: LanguageServer, logMessage message: LogMessageParams)
    func languageServer(_ server: LanguageServer, showMessage message: ShowMessageParams)
    func languageServer(_ server: LanguageServer, showMessageRequest messageRequest: ShowMessageRequestParams)
    func languageServer(_ server: LanguageServer, publishDiagnostics diagnosticsParams: PublishDiagnosticsParams)

    func languageServer(_ server: LanguageServer, failedToDecodeNotification notificationName: String, with error: Error)
}
