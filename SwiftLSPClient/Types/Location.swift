//
//  Location.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-01-21.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct Location {
    public let uri: DocumentUri
    public let range: LSPRange
}

extension Location: Codable {
}

extension Location: Hashable {
}
