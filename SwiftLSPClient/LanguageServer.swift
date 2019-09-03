//
//  LanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public enum LanguageServerError: Error {
    case serverUnavailable
    case protocolError(Error)
    case invalidDocumentURI(URL)
    case unableToEncodeRequest
    case unableToDecodeResponse(Error)
    case missingExpectedResult
    case operationTimedOut
    case unimplemented
    
    case serverError(code: Int, message: String, data: [String : AnyObject]?)
}

public typealias LanguageServerResult<T> = Result<T, LanguageServerError>

public protocol LanguageServer: class {
    var notificationResponder: NotificationResponder? { get set }

    func initialize(params: InitializeParams, block: @escaping (LanguageServerResult<InitializationResponse>) -> Void)
    
    func didOpenTextDocument(params: DidOpenTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didChangeTextDocument(params: DidChangeTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didCloseTextDocument(params: DidCloseTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func willSaveTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func willSaveWaitUntilTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerResult<WillSaveWaitUntilResponse>) -> Void)
    func didSaveTextDocument(params: DidSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    
    func completion(params: CompletionParams, block: @escaping (LanguageServerResult<CompletionResponse>) -> Void)
    func hover(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<Hover>) -> Void)
    func signatureHelp(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<SignatureHelp>) -> Void)
    func typeDefinition(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<TypeDefinitionResponse?>) -> Void)
    func documentSymbol(params: DocumentSymbolParams, block: @escaping (LanguageServerResult<DocumentSymbolResponse>) -> Void)

    func formatting(params: DocumentFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func rangeFormatting(params: DocumentRangeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
    func onTypeFormatting(params: DocumentOnTypeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void)
}

public protocol NotificationResponder: class {
    func languageServerInitialized(_ server: LanguageServer)

    func languageServer(_ server: LanguageServer, logMessage message: LogMessageParams)
    func languageServer(_ server: LanguageServer, showMessage message: ShowMessageParams)
    func languageServer(_ server: LanguageServer, showMessageRequest messageRequest: ShowMessageRequestParams)
    func languageServer(_ server: LanguageServer, publishDiagnostics diagnosticsParams: PublishDiagnosticsParams)

    func languageServer(_ server: LanguageServer, failedToDecodeNotification notificationName: String, with error: Error)
}
