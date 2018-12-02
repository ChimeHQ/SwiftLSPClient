//
//  RemoteLanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation
import Result

public class JSONRPCLanguageServer {
    private var messageId: Int
    private let protocolTransport: ProtocolTransport
    
    public init(dataTransport: DataTransport) {
        self.messageId = 0

        self.protocolTransport = ProtocolTransport(dataTransport: dataTransport)
    }
}

private func relayResult<T>(result: JSONRPCLanguageServer.ProtocolResponse<T>, block: @escaping (LanguageServerResult<T>) -> Void) {
    switch result {
    case .failure(let error):
        block(.failure(.protocolError(error)))
    case .success(let responseMessage):
        if let responseParam = responseMessage.result {
            block(.success(responseParam))
        } else {
            block(.failure(.missingExpectedResult))
        }
    }
}

extension JSONRPCLanguageServer: LanguageServer {
    typealias ProtocolResponse<T: Codable> = ProtocolTransport.ResponseResult<T>
    
    public func initialize(params: InitalizeParams, block: @escaping (LanguageServerResult<InitializationResponse>) -> Void) {
        let method = ProtocolMethod.Initialize
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<InitializationResponse>) in
            relayResult(result: result, block: block)
        }
    }
    
    public func hover(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<Hover>) -> Void) {
        let method = ProtocolMethod.TextDocument.Hover
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<Hover>) in
            relayResult(result: result, block: block)
        }
    }
    
    public func didOpenTextDocument(params: DidOpenTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.DidOpen
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func didCloseTextDocument(params: DidOpenTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.DidOpen
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func didChangeTextDocument(params: DidChangeTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.DidChange
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func didCloseTextDocument(params: DidCloseTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.DidClose
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func didSaveTextDocument(params: DidSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.DidSave
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func completion(params: CompletionParams, block: @escaping (LanguageServerResult<CompletionResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Completion
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<CompletionResponse>) in
            relayResult(result: result, block: block)
        }
    }
}
