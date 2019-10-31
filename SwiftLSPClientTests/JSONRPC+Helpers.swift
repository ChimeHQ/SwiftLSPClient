//
//  JSONRPC+Helpers.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-10-30.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import SwiftLSPClient

protocol ProtocolEncodable: Encodable {
}

extension ProtocolEncodable {
    func encodeToProtocolData() throws -> Data {
        let payloadData = try JSONEncoder().encode(self)

        return MessageTransport.prependHeaders(to: payloadData)
    }
}

extension JSONRPCResultResponse: ProtocolEncodable {
}

extension JSONRPCNotificationParams: ProtocolEncodable {
}

extension JSONRPCRequest: ProtocolEncodable {
}
