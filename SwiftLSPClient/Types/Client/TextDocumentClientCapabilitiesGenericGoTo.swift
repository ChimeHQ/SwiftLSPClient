//
//  TextDocumentClientCapabilitiesGenericGoTo.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-09-09.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct TextDocumentClientCapabilitiesGenericGoTo: Codable {
    public let dynamicRegistration: Bool?
    public let linkSupport: Bool?

    public init(dynamicRegistration: Bool?, linkSupport: Bool?) {
        self.dynamicRegistration = dynamicRegistration
        self.linkSupport = linkSupport
    }
}
