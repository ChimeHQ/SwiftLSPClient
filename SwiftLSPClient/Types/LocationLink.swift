//
//  LocationLink.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-13.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct LocationLink {
    public let originSelectionRange: LSPRange?
    public let targetUri: String
    public let targetRange: LSPRange
    public let targetSelectionRange: LSPRange
}

extension LocationLink: Codable {
}
