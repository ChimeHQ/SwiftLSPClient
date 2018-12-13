//
//  LanguageServerProcessHost.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-12-02.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public class LanguageServerProcessHost {
    private let process: Process
    private let transport: StdioDataTransport
    private let server: LanguageServer

    public init(path: String, arguments: [String]) {
        self.process = Process()
        self.transport = StdioDataTransport()
        self.server = JSONRPCLanguageServer(dataTransport: transport)

        process.standardInput = transport.stdinPipe
        process.standardOutput = transport.stdoutPipe
        process.standardError = transport.stderrPipe

        process.launchPath = path
        process.arguments = arguments

        process.terminationHandler = { [unowned self] (task) in
            self.transport.close()
        }
    }

    public func start(block: @escaping (LanguageServer?) -> Void) {
        process.launch()

        block(server)
    }

    public func stop(block: @escaping () -> Void) {
        process.terminate()

        block()
    }
}
