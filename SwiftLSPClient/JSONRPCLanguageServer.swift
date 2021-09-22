//
//  RemoteLanguageServer.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation
import JSONRPC
import AnyCodable

extension AnyJSONRPCResponse {
    public init(error: Error, for request: AnyJSONRPCRequest) {
        self.init(id: request.id,
                  errorCode: JSONRPCErrors.internalError,
                  message: error.localizedDescription)
    }
}

public class JSONRPCLanguageServer {
    private var messageId: Int
    let protocolTransport: ProtocolTransport
    public weak var notificationResponder: NotificationResponder?
    public var configurationHandler: ConfigurationHandler?
    public var registrationHandler: RegistrationHandler?
    public var unregistrationHandler: UnregistrationHandler?
    public var semanticTokenRefreshHandler: SemanticTokenRefreshHandler?
    
    public init(dataTransport: DataTransport) {
        self.messageId = 0

        let msgTransport = MessageTransport(dataTransport: dataTransport)
        self.protocolTransport = ProtocolTransport(messageTransport: msgTransport)

        protocolTransport.notificationHandler = { [unowned self] (notification, data, callback) in
            self.handleNotification(notification, data: data, completionHandler: callback)
        }

        protocolTransport.requestHandler = { [unowned self] (request, data, callback) in
            self.handleRequest(request, data: data, completionHandler: callback)
        }
    }
}

extension JSONRPCLanguageServer {
    private func decodeNotification<T: Codable>(named name: String, data: Data, onSuccess: (T) -> Void) {
        let responder = notificationResponder

        do {
            let resultType = JSONRPCNotification<T>.self
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

    private func handleNotification(_ notification: AnyJSONRPCNotification, data: Data, completionHandler: @escaping (Error?) -> Void) {
        guard let responder = notificationResponder else {
            completionHandler(nil)
            return
        }

        let method = notification.method

        switch method {
        case ProtocolMethod.Window.LogMessage:
            decodeNotification(named: method, data: data) { (value: LogMessageParams) in
                responder.languageServer(self, logMessage: value)
            }
        case ProtocolMethod.Window.ShowMessage:
            decodeNotification(named: method, data: data) { (value: ShowMessageParams) in
                responder.languageServer(self, showMessage: value)
            }
        case ProtocolMethod.Window.ShowMessageRequest:
            decodeNotification(named: method, data: data) { (value: ShowMessageRequestParams) in
                responder.languageServer(self, showMessageRequest: value)
            }
        case ProtocolMethod.TextDocument.PublishDiagnostics:
            decodeNotification(named: method, data: data) { (value: PublishDiagnosticsParams) in
                responder.languageServer(self, publishDiagnostics: value)
            }
        default:
            break
        }
    }

    private func decodeRequest<T: Codable>(named name: String, data: Data) throws -> T {
        let resultType = JSONRPCRequest<T>.self
        let result = try JSONDecoder().decode(resultType, from: data)

        guard let params = result.params else {
            throw LanguageServerError.missingExpectedParameter
        }

        return params
    }

    private func handleResultRequest(_ request: AnyJSONRPCRequest, data: Data, completionHandler: @escaping (Result<AnyCodable?, Error>) -> Void) {
        let method = request.method

        do {
            switch method {
            case ProtocolMethod.Workspace.Configuration:
                let params: ConfigurationParams = try decodeRequest(named: method, data: data)

                guard let handler = configurationHandler else {
                    throw LanguageServerError.requestHandlerUnavailable(method)
                }

                handler(params, { result in
                    completionHandler(result.map({ resultItems in
                        return AnyCodable(arrayLiteral: resultItems)
                    }))
                })
            case ProtocolMethod.Client.RegisterCapability:
                let params: RegistrationParams = try decodeRequest(named: method, data: data)

                guard let handler = registrationHandler else {
                    throw LanguageServerError.requestHandlerUnavailable(method)
                }

                handler(params, { result in
                    if let error = result {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.success(nil))
                    }
                })
            case ProtocolMethod.Client.UnregisterCapability:
                let params: UnregistrationParams = try decodeRequest(named: method, data: data)

                guard let handler = unregistrationHandler else {
                    throw LanguageServerError.requestHandlerUnavailable(method)
                }

                handler(params, { result in
                    if let error = result {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.success(nil))
                    }
                })
            case ProtocolMethod.Workspace.SemanticTokens.Refresh:
                guard let handler = semanticTokenRefreshHandler else {
                    throw LanguageServerError.requestHandlerUnavailable(method)
                }

                handler({ result in
                    if let error = result {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.success(nil))
                    }
                })
            default:
                throw LanguageServerError.unimplemented
            }
        } catch {
            completionHandler(.failure(error))
        }
    }

    private func handleRequest(_ request: AnyJSONRPCRequest, data: Data, completionHandler: @escaping (AnyJSONRPCResponse) -> Void) {
        handleResultRequest(request, data: data) { result in
            switch result {
            case .failure(let error):
                let response = AnyJSONRPCResponse(error: error, for: request)

                completionHandler(response)
            case .success(let response):
                let response = AnyJSONRPCResponse(id: request.id, result: response)

                completionHandler(response)
            }
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
            let serverError = LanguageServerError.serverError(code: errorParam.code, message: errorParam.message, data: errorParam.data)

            block(.failure(serverError))
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
    
    public func prepareRename(params: PrepareRenameParams, block: @escaping (LanguageServerResult<PrepareRenameResponse?>) -> Void) {
        let method = ProtocolMethod.TextDocument.PrepareRename
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<PrepareRenameResponse?>) in
            relayResult(result: result, block: block)
        }
    }
    
    public func rename(params: RenameParams, block: @escaping (LanguageServerResult<RenameResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.Rename
        
        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<RenameResponse>) in
            relayResult(result: result, block: block)
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

    public func codeAction(params: CodeActionParams, block: @escaping (LanguageServerResult<CodeActionResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.CodeAction

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<CodeActionResponse>) in
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

    public func semanticTokensFull(params: SemanticTokensParams, block: @escaping (LanguageServerResult<SemanticTokens>) -> Void) {
        let method = ProtocolMethod.TextDocument.SemanticTokens.Full

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<SemanticTokens>) in
            relayResult(result: result, block: block)
        }
    }

    public func semanticTokensFullDelta(params: SemanticTokensDeltaParams, block: @escaping (LanguageServerResult<SemanticTokensDeltaResponse>) -> Void) {
        let method = ProtocolMethod.TextDocument.SemanticTokens.FullDelta

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<SemanticTokensDeltaResponse>) in
            relayResult(result: result, block: block)
        }
    }

    public func semanticTokensRange(params: SemanticTokensRangeParams, block: @escaping (LanguageServerResult<SemanticTokens>) -> Void) {
        let method = ProtocolMethod.TextDocument.SemanticTokens.Range

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<SemanticTokens>) in
            relayResult(result: result, block: block)
        }
    }

    public func fullSemanticTokens(params: SemanticTokensParams, block: @escaping (LanguageServerError?) -> Void) {
        let method = ProtocolMethod.TextDocument.SemanticTokens.Full

        protocolTransport.sendRequest(params, method: method) { (result: ProtocolResponse<AnyCodable>) in
            relayResult(result: result, block: { (a) in
                print(a)

                switch a {
                case .failure(let error):
                    block(error)
                case .success(let value):
                    print(value)

                    block(nil)
                }
            })
        }
    }
}
