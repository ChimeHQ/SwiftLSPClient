//
//  WorkspaceFolder.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public struct WorkspaceFolder: Codable {
    public let uri: String
    public let name: String

    public init(uri: String, name: String) {
        self.uri = uri
        self.name = name
    }
}

typealias WorkspaceFolderResult = [WorkspaceFolder]?
