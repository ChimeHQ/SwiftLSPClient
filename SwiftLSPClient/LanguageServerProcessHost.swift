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
    private var launched: Bool

    public init(path: String, arguments: [String], environment: [String : String] = [:]) {
        self.process = Process()
        self.transport = StdioDataTransport()
        self.server = JSONRPCLanguageServer(dataTransport: transport)
        self.launched = false

        process.standardInput = transport.stdinPipe
        process.standardOutput = transport.stdoutPipe
        process.standardError = transport.stderrPipe

        process.launchPath = path
        process.arguments = arguments
        process.environment = environment

        process.terminationHandler = { [unowned self] (task) in
            self.transport.close()
        }
    }

    public func start(block: @escaping (LanguageServer?) -> Void) {
        process.launch()
        launched = true

        block(server)
    }

    public func stop(block: @escaping () -> Void) {
        if launched {
            process.terminate()
        }

        block()
    }

    public func getServer(_ block: @escaping (LanguageServer?) -> Void) {
        switch (process.isRunning, launched) {
        case (true, true):
            block(server)
        case (true, false):
            // nonsense state
            block(nil)
        case (false, true):
            block(nil)
        case (false, false):
            start { (s) in
                block(s)
            }
        }
    }
}
