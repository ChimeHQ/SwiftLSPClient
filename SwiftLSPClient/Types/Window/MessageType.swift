//
//  MessageType.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-09-02.
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
