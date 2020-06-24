//
//  JSONRPC.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Matt Massicotte. All rights reserved.
//

import Foundation

public enum JSONId: Codable, Hashable {
    case numericId(Int)
    case stringId(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .numericId(value)
        } else if let value = try? container.decode(String.self) {
            self = .stringId(value)
        } else {
            let ctx = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown JSONId Type")
            throw DecodingError.typeMismatch(JSONValue.self, ctx)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .numericId(let value):
            try container.encode(value)
        case .stringId(let value):
            try container.encode(value)
        }
    }
}

extension JSONId: CustomStringConvertible {
    public var description: String {
        switch self {
        case .stringId(let str):
            return str
        case .numericId(let num):
            return String(num)
        }
    }
}

public enum ProtocolErrorCode: Int, Codable {
    case parseError = -32700
    case invalidRequest = -32600
    case methodNotFound = -32601
    case invalidParams = -32602
    case internalError = -32603
    case serverErrorStart = -32099
    case serverErrorEnd = -32000
    case serverNotInitialized = -32002
    case unknownErrorCode = -32001
    
    case requestCancelled = -32800
}

// MARK: Requests, Responses, and Errors
public struct JSONRPCRequest<T>: Codable where T: Codable {
    public var jsonrpc = "2.0"
    public let id: JSONId
    public let method: String
    public let params: T?

    public init(id: JSONId, method: String, params: T? = nil) {
        self.id = id
        self.method = method
        self.params = params
    }

    public init(id: Int, method: String, params: T? = nil) {
        let numericId = JSONId.numericId(id)

        self.init(id: numericId, method: method, params: params)
    }
}

public struct ResponseError: Codable {
    public let code: Int
    public let message: String
    public let data: JSONValue?

    public var languageServerError: LanguageServerError {
        return LanguageServerError.serverError(code: code, message: message, data: nil)
    }
}

public struct JSONRPCResponse: Codable {
    public var jsonrpc: String
    public let id: JSONId
    public let error: ResponseError?
}

public struct JSONRPCResultResponse<T>: Codable where T: Codable {
    public var jsonrpc: String
    public let id: JSONId?
    public let result: T?
    public let error: ResponseError?

    public init(id: JSONId, result: T) {
        self.jsonrpc = "2.0"
        self.id = id
        self.result = result
        self.error = nil
    }

    public init(id: Int, result: T) {
        self.jsonrpc = "2.0"
        self.id = JSONId.numericId(id)
        self.result = result
        self.error = nil
    }

    public init(id: JSONId, error: ResponseError) {
        self.jsonrpc = "2.0"
        self.id = id
        self.result = nil
        self.error = error
    }
}

public struct JSONRPCNotification: Codable {
    public var jsonrpc = "2.0"
    public let method: String
}

extension JSONRPCNotification: CustomStringConvertible {
    public var description: String {
        return "<JSONRPCNotification: \(method)>"
    }
}

public struct JSONRPCNotificationParams<T>: Codable where T: Codable {
    public var jsonrpc = "2.0"
    public let method: String
    public let params: T?
}
