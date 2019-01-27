//
//  General.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-13.
//  Copyright © 2018 Matt Massicotte. All rights reserved.
//

import Foundation

public enum Tracing: String, Codable {
    case off
    case messages
    case verbose
}

public struct InitializeParams: Codable {
    public let processId: Int
    public let rootPath: String?
    public let rootURI: DocumentUri?
    public let initializationOptions: JSONValue?
    public let capabilities: ClientCapabilities
    public let trace: Tracing?
    public let workspaceFolders: [WorkspaceFolder]?
    
    public init(processId: Int, rootPath: String?, rootURI: DocumentUri?, initializationOptions: JSONValue?, capabilities: ClientCapabilities, trace: Tracing?, workspaceFolders: [WorkspaceFolder]?) {
        self.processId = processId
        self.rootPath = rootPath
        self.rootURI = rootURI
        self.initializationOptions = initializationOptions
        self.capabilities = capabilities
        self.trace = trace
        self.workspaceFolders = workspaceFolders
    }
}

public struct InitializationResponse: Codable {
    public let capabilities: ServerCapabilities
}
