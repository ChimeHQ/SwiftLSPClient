//
//  ShowMessageRequest.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-09-01.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct ShowMessageRequestParams {
    public let type: MessageType
    public let message: String
    public let actions: [MessageActionItem]?
}

extension ShowMessageRequestParams: Codable {
}

extension ShowMessageRequestParams: CustomStringConvertible {
    public var description: String {
        return "\(type): \(message)"
    }
}

public struct MessageActionItem {
    public let title: String
}

extension MessageActionItem: Codable {
}
