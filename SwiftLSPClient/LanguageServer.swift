//
//  LanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation
import Result

public enum LanguageServerError: Error {
    case protocolError(Error)
    case invalidDocumentURI(URL)
    case unableToEncodeRequest
    case missingExpectedResult
    
    case serverError(ProtocolErrorCode, String, [String: AnyObject]?)
}

public typealias LanguageServerResult<T> = Result<T, LanguageServerError>

public protocol LanguageServer {
    func initialize(params: InitalizeParams, block: @escaping (LanguageServerResult<InitializationResponse>) -> Void)
    
    func didOpenTextDocument(params: DidOpenTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didChangeTextDocument(params: DidChangeTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didCloseTextDocument(params: DidCloseTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    func didSaveTextDocument(params: DidSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void)
    
    func completion(params: CompletionParams, block: @escaping (LanguageServerResult<CompletionResponse>) -> Void)
    func hover(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<Hover>) -> Void)
    func signatureHelp(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<SignatureHelp>) -> Void)
}
