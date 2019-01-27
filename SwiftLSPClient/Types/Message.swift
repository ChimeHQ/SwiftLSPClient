//
//  Message.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum MessageType: Int, Codable {
    case error = 1
    case warning = 2
    case info = 3
    case log = 4
}

extension MessageType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .error:
            return "error"
        case .warning:
            return "warning"
        case .info:
            return "info"
        case .log:
            return "log"
        }
    }
}

public struct LogMessageParams: Codable {
    public let type: MessageType
    public let message: String
}

extension LogMessageParams: CustomStringConvertible {
    public var description: String {
        return "\(type): \(message)"
    }
}

public typealias ShowMessageParams = LogMessageParams
