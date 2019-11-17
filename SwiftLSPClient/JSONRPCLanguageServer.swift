//
//  RemoteLanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public class JSONRPCLanguageServer {
    private var messageId: Int
    private let protocolTransport: ProtocolTransport
    public weak var notificationResponder: NotificationResponder?
    
    public init(dataTransport: DataTransport) {
        self.messageId = 0

        self.protocolTransport = ProtocolTransport(dataTransport: dataTransport)

        self.protocolTransport.delegate = self
    }
}

extension JSONRPCLanguageServer: ProtocolTransportDelegate {
    public func transportReceived(_ transport: ProtocolTransport, undecodableData data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            print("undecodable data received: \(string)")
        } else {
            print("undecodable data received: \(data)")
        }
    }

    public func transportReceived(_ transport: ProtocolTransport, notificationMethod: String, data: Data) {
        guard let responder = notificationResponder else {
            return
        }

        switch notificationMethod {
        case ProtocolMethod.Window.LogMessage:
            decodeNotification(named: notificationMethod, data: data) { (value: LogMessageParams) in
                responder.languageServer(self, logMessage: value)
            }
        case ProtocolMethod.Window.ShowMessage:
            decodeNotification(named: notificationMethod, data: data) { (value: ShowMessageParams) in
                responder.languageServer(self, showMessage: value)
            }
        case ProtocolMethod.Window.ShowMessageRequest:
            decodeNotification(named: notificationMethod, data: data) { (value: ShowMessageRequestParams) in
                responder.languageServer(self, showMessageRequest: value)
            }
        case ProtocolMethod.TextDocument.PublishDiagnostics:
            decodeNotification(named: notificationMethod, data: data) { (value: PublishDiagnosticsParams) in
                responder.languageServer(self, publishDiagnostics: value)
            }
        default:
            break
        }
    }

    private func decodeNotification<T: Codable>(named name: String, data: Data, onSuccess: (T) -> Void) {
        let responder = notificationResponder

        do {
            let resultType = JSONRPCNotificationParams<T>.self
            let result = try JSONDecoder().decode(resultType, from: data)

            guard let params = result.params else {
                responder?.languageServer(self, failedToDecodeNotification: name, with: LanguageServerError.missingExpectedResult)

                return
            }

            return onSuccess(params)
        } catch {
            let newError = LanguageServerError.unableToDecodeResponse(error)

            responder?.languageServer(self, failedToDecodeNotification: name, with: newError)
        }
    }
}

private func relayResult<T>(result: JSONRPCLanguageServer.ProtocolResponse<T>, block: @escaping (LanguageServerResult<T>) -> Void) {
    switch result {
    case .failure(let error):
        block(.failure(.protocolError(error)))
    case .success(let responseMessage):
        if let responseParam = responseMessage.result {
            block(.success(responseParam))
        } else if let errorParam = responseMessage.error {
            block(.failure(errorParam.languageServerError))
        } else {
            block(.failure(.missingExpectedResult))
        }
    }
}

extension JSONRPCLanguageServer: LanguageServer {
    typealias ProtocolResponse<T: Codable> = ProtocolTransport.ResponseResult<T>
    
    public func initialize(params: InitializeParams, block: @escaping (LanguageServerResult<InitializationResponse>) -> Void) {
        let method = ProtocolMethod.Initialize
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<InitializationResponse>) in
            relayResult(result: result, block: block)
        }
    }
    
    public func initialized(params: InitializedParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.Initialized
        
        protocolTransport.sendNotification(params, method: method) { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }
    
    public func hover(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<HoverResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Hover
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<HoverResponse>) in
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

    public func willSaveTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.WillSave

        protocolTransport.sendNotification(params, method: method)  { (error) in
            let upstreamError = error.map { LanguageServerError.protocolError($0) }
            block(upstreamError)
        }
    }

    public func willSaveWaitUntilTextDocument(params: WillSaveTextDocumentParams, block: @escaping (LanguageServerResult<WillSaveWaitUntilResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.WillSaveWaitUntil

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<WillSaveWaitUntilResponse>) in
            relayResult(result: result, block: block)
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

    public func signatureHelp(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<SignatureHelpResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.SignatureHelp

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<SignatureHelpResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func declaration(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<DeclarationResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Declaration

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<DeclarationResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func definition(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<DefinitionResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Definition

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<DefinitionResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func typeDefinition(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<TypeDefinitionResponse?>) -> Void) {
        let method = ProtocolMethod.TextDocument.TypeDefinition

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<TypeDefinitionResponse?>) in
            relayResult(result: result, block: block)
        }
    }

    public func implementation(params: TextDocumentPositionParams, block: @escaping (LanguageServerResult<ImplementationResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Implementation

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<ImplementationResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func documentSymbol(params: DocumentSymbolParams, block: @escaping (LanguageServerResult<DocumentSymbolResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.DocumentSymbol

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<DocumentSymbolResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func formatting(params: DocumentFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void) {
        let method = ProtocolMethod.TextDocument.Formatting

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<FormattingResult>) in
            relayResult(result: result, block: block)
        }
    }

    public func rangeFormatting(params: DocumentRangeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void) {
        let method = ProtocolMethod.TextDocument.RangeFormatting

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<FormattingResult>) in
            relayResult(result: result, block: block)
        }
    }

    public func onTypeFormatting(params: DocumentOnTypeFormattingParams, block: @escaping (LanguageServerResult<FormattingResult>) -> Void) {
        let method = ProtocolMethod.TextDocument.OnTypeFormatting

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<FormattingResult>) in
            relayResult(result: result, block: block)
        }
    }

    public func references(params: ReferenceParams, block: @escaping (LanguageServerResult<ReferenceResponse?>) -> Void) {
        let method = ProtocolMethod.TextDocument.References

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<ReferenceResponse?>) in
            relayResult(result: result, block: block)
        }
    }

    public func foldingRange(params: FoldingRangeParams, block: @escaping (LanguageServerResult<FoldingRangeResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.FoldingRange

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<FoldingRangeResponse>) in
            relayResult(result: result, block: block)
        }
    }
}
