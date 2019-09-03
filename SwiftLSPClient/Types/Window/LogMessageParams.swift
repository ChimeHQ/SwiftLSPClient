//
//  LogMessageParams.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-27.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct LogMessageParams: Codable {
    public let type: MessageType
    public let message: String
}

extension LogMessageParams: CustomStringConvertible {
    public var description: String {
        return "\(type): \(message)"
    }
}
