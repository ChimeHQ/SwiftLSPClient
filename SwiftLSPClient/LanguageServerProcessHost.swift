//
//  LanguageServerProcessHost.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-12-02.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

/// Represents a locally-running language server process.
///
/// This class can be used to start and manage a language server process that
/// runs on the local machine. It provides some convenience in that case, but
/// if more control of the process is necessary, you can use StdioDataTransport
/// and JSONRPCLanguageServer directy.
///
/// - Note: This class is not thread-safe. It is the caller's responsibility to
/// ensure there are no concurrent accesses.
public class LanguageServerProcessHost {
    private let process: Process
    private let transport: StdioDataTransport
    private let server: LanguageServer
    private var launched: Bool
    public var terminationHandler: (() -> Void)?

    /// Initialize an object that represents a locally-running language server process.
    ///
    /// A language server's behavior is often highly dependent on arguments and the
    /// executable environment. Pay special attention to the environment, as there could
    /// be configuration in a local shell environment that is **not** inherited by the
    /// calling process.
    ///
    /// - Parameters:
    ///   - path: The language server's executable path on disk.
    ///   - arguments: Command line arguments passed to the executable when launched.
    ///   - environment: Environment variables applied to the executable. If nil, the environemnt is inherited from the calling process.
    public init(path: String, arguments: [String], environment: [String : String]? = nil) {
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
            self.terminationHandler?()
        }
    }

    /// Start the language server process.
    ///
    /// - Parameter block: This block is invoked once the server has been started, or will nil to indicate failure.
    public func start(block: @escaping (LanguageServer?) -> Void) {
        process.launch()
        launched = true

        block(server)
    }

    /// Stop the language server process.
    ///
    /// - Parameter block: This block is invoked once the process has been terminated.
    public func stop(block: @escaping () -> Void) {
        if launched {
            process.terminate()
        }

        block()
    }

    /// Get a reference to the hosted languauge server.
    ///
    /// This method idempotent. It is safe to call this any time you need a
    /// reference to the server. If it is not started, it will be started first
    /// before invoking the supplied block.
    ///
    /// - Note: Like the rest of this class, this method is not thread-safe.
    ///
    /// - Parameter block: This block will be invoked with the started server, or
    /// nil if it is not running or failed to start.
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
