//
//  ProtocolTransport.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-14.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public enum ProtocolTransportError: Error {
    case encodingFailure(Error)
    case decodingFailure(Error)
    case transportSendFailure(Error)
    case responderRelayFailure(Error)
}

public protocol ProtocolTransportDelegate: class {
    func transportReceived(_ transport: ProtocolTransport, undecodableData data: Data)
    func transportReceived(_ transport: ProtocolTransport, notificationMethod: String, data: Data)
}

public class ProtocolTransport {
    public typealias ResponseResult<T: Codable> = Result<JSONRPCResultResponse<T>, ProtocolTransportError>
    public typealias DataResult = Result<Data, ProtocolTransportError>
    public typealias MessageResponder = (DataResult) -> Void
    
    private var id = 1
    private let messageTransport: MessageTransport
    private var responders: [JSONId: MessageResponder]
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    public weak var delegate: ProtocolTransportDelegate?
    private let queue: DispatchQueue
    
    public init(messageTransport: MessageTransport) {
        self.messageTransport = messageTransport
        self.responders = [:]
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.queue = DispatchQueue(label: "com.chimehq.SwiftLSPClient.ProtocolTransport")
        
        self.messageTransport.dataHandler = { [unowned self] (data) in
            self.dataAvailable(data)
        }
    }

    public convenience init(dataTransport: DataTransport) {
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        
        self.init(messageTransport: messageTransport)
    }
    
    private func generateID() -> JSONId {
        let issuedId = JSONId.numericId(id)
        
        id += 1
        
        return issuedId
    }
    
    public func sendRequest<T, U>(_ request: T, method: String, responseHandler: @escaping (ResponseResult<U>) -> Void) where T: Codable, U: Decodable {
        queue.async {
            let issuedId = self.generateID()

            let rpcRequest = JSONRPCRequest(id: issuedId, method: method, params: request)

            let jsonData: Data

            do {
                jsonData = try self.encoder.encode(rpcRequest)
            } catch {
                responseHandler(.failure(.encodingFailure(error)))
                return
            }

            self.messageTransport.write(jsonData)

            self.responders[issuedId] = { [unowned self] (result) in
                self.relayResponse(result: result, responseHandler: responseHandler)
            }
        }
    }

    private func relayResponse<T>(result: DataResult, responseHandler: @escaping (ResponseResult<T>) -> Void) where T: Decodable {
        switch result {
        case .failure(let error):
            responseHandler(.failure(.responderRelayFailure(error)))
        case .success(let data):
            queue.async {
                do {
                    let jsonResult = try self.decoder.decode(JSONRPCResultResponse<T>.self, from: data)

                    responseHandler(.success(jsonResult))
                } catch {
                    responseHandler(.failure(.decodingFailure(error)))
                }
            }
        }
    }
    
    public func sendNotification<T>(_ params: T, method: String, block: @escaping (ProtocolTransportError?) -> Void) where T: Codable {
        let notification = JSONRPCNotificationParams(method: method, params: params)

        queue.async {
            let jsonData: Data

            do {
                jsonData = try self.encoder.encode(notification)
            } catch {
                block(.encodingFailure(error))
                return
            }

            self.messageTransport.write(jsonData)

            block(nil)
        }
    }
    
    private func dataAvailable(_ data: Data) {
        queue.async {
            if let message = try? self.decoder.decode(JSONRPCResponse.self, from: data) {
                self.dispatchMessage(message, originalData: data)
                return
            }

            if let notification = try? self.decoder.decode(JSONRPCNotification.self, from: data) {
                self.dispatchNotification(notification, originalData: data)
                return
            }

            self.delegate?.transportReceived(self, undecodableData: data)
        }
    }
    
    private func dispatchMessage(_ message: JSONRPCResponse, originalData data: Data) {
        if #available(OSX 10.12, *) {
            dispatchPrecondition(condition: .onQueue(queue))
        }

        guard let responder = responders[message.id] else {
            // hrm, got a message without a matching responder
            print("not matching responder for \(message.id), dropping message")
            return
        }
            
        responder(.success(data))

        // TODO: This doesn't seem to be threadsafe
        responders.removeValue(forKey: message.id)
    }
    
    private func dispatchNotification(_ notification: JSONRPCNotification, originalData data: Data) {
        let method = notification.method

        self.delegate?.transportReceived(self, notificationMethod: method, data: data)
    }
}

