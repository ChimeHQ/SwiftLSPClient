//
//  JSONRPC.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Matt Massicotte. All rights reserved.
//

import Foundation

// MARK: Basic JSON types
public enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String : JSONValue])
    case array([JSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String : JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            let ctx = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown JSON Type")
            throw DecodingError.typeMismatch(JSONValue.self, ctx)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}

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
    public let jsonrpc = "2.0"
    public let id: JSONId
    public let method: String
    public let params: T?
}

public struct ResponseError: Codable {
    let code: ProtocolErrorCode
    let message: String
    let data: JSONValue
}

public struct JSONRPCResponse: Codable {
    public let jsonrpc: String
    public let id: JSONId
    public let error: ResponseError?
}

public struct JSONRPCResultResponse<T>: Codable where T: Codable {
    public let jsonrpc: String
    public let id: JSONId?
    public let result: T?
    public let error: ResponseError?
}

public struct JSONRPCNotification: Codable {
    public let jsonrpc = "2.0"
    public let method: String
}

public struct JSONRPCNotificationParams<T>: Codable where T: Codable {
    public let jsonrpc = "2.0"
    public let method: String
    public let params: T?
}
