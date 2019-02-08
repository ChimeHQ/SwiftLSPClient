//
//  MockProtocolTransportMessage.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-08.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import SwiftLSPClient

class MockProtocolTransportDelegate: ProtocolTransportDelegate {
    var notificationHandler: ((String, Data) -> Void)?

    func transportReceived(_ transport: ProtocolTransport, undecodableData data: Data) {
    }

    func transportReceived(_ transport: ProtocolTransport, notificationMethod: String, data: Data) {
        notificationHandler?(notificationMethod, data)
    }
}
