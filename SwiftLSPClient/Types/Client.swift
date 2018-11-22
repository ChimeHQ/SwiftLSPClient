//
//  Client.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public struct TextDocumentRegistrationOptions: Codable {
    public let documentSelector: DocumentSelector?
}
