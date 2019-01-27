//
//  ProtocolTransport.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-14.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation
import Result

enum ProtocolTransportError: Error {
    case encodingFailure(Error)
    case decodingFailure(Error)
    case transportSendFailure(Error)
    case responderRelayFailure(Error)
}

protocol ProtocolTransportDelegate: class {
    func transportReceived(_ transport: ProtocolTransport, undecodableData data: Data)
    func transportReceived(_ transport: ProtocolTransport, notificationMethod: String, data: Data)
}

class ProtocolTransport {
    public typealias ResponseResult<T: Codable> = Result<JSONRPCResultResponse<T>, ProtocolTransportError>
    public typealias DataResult = Result<Data, ProtocolTransportError>
    public typealias MessageResponder = (DataResult) -> Void
    
    private var id = 1
    private var messageTransport: MessageTransport
    private var responders: [JSONId: MessageResponder]
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    public weak var delegate: ProtocolTransportDelegate?
    
    init(messageTransport: MessageTransport) {
        self.messageTransport = messageTransport
        self.responders = [:]
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        self.messageTransport.dataHandler = { [unowned self] (data) in
            self.dataAvailable(data)
        }
    }

    convenience init(dataTransport: DataTransport) {
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        
        self.init(messageTransport: messageTransport)
    }
    
    private func generateID(_ handler: (JSONId) -> Void) {
        let issuedId = JSONId.numericId(id)
        
        id += 1
        
        handler(issuedId)
    }
    
    func sendRequest<T, U>(_ request: T, method: String, responseHandler: @escaping (ResponseResult<U>) -> Void) where T: Codable, U: Decodable {
        generateID { (issuedId) in
            let rpcRequest = JSONRPCRequest(id: issuedId, method: method, params: request)
            
            let jsonData: Data
            
            do {
                jsonData = try self.encoder.encode(rpcRequest)
            } catch {
                responseHandler(.failure(.encodingFailure(error)))
                return
            }
            
            do {
                try self.messageTransport.sendMessage(jsonData)
                
                responders[issuedId] = { [unowned self] (result) in
                    self.relayResponse(result: result, responseHandler: responseHandler)
                }
            } catch {
                responseHandler(.failure(.transportSendFailure(error)))
            }
        }
    }
    
    private func relayResponse<T>(result: DataResult, responseHandler: @escaping (ResponseResult<T>) -> Void) where T: Decodable {
        switch result {
        case .failure(let error):
            responseHandler(.failure(.responderRelayFailure(error)))
        case .success(let data):
            do {
                let jsonResult = try self.decoder.decode(JSONRPCResultResponse<T>.self, from: data)

                responseHandler(.success(jsonResult))
            } catch {
                responseHandler(.failure(.decodingFailure(error)))
            }
        }
    }
    
    func sendNotification<T>(_ params: T, method: String, block: @escaping (ProtocolTransportError?) -> Void) where T: Codable {
        let notification = JSONRPCNotificationParams(method: method, params: params)
        
        let jsonData: Data
        
        do {
            jsonData = try self.encoder.encode(notification)
        } catch {
            block(.encodingFailure(error))
            return
        }
        
        do {
            try self.messageTransport.sendMessage(jsonData)
            block(nil)
        } catch {
            block(.transportSendFailure(error))
        }
    }
    
    private func dataAvailable(_ data: Data) {
        if let message = try? self.decoder.decode(JSONRPCResponse.self, from: data) {
            dispatchMessage(message, originalData: data)
            return
        }
        
        if let notification = try? self.decoder.decode(JSONRPCNotification.self, from: data) {
            dispatchNotification(notification, originalData: data)
            return
        }

        self.delegate?.transportReceived(self, undecodableData: data)
    }
    
    private func dispatchMessage(_ message: JSONRPCResponse, originalData data: Data) {
        let responder = responders[message.id]
            
        responder?(.success(data))
    }
    
    private func dispatchNotification(_ notification: JSONRPCNotification, originalData data: Data) {
        let method = notification.method

        self.delegate?.transportReceived(self, notificationMethod: method, data: data)
    }
}

