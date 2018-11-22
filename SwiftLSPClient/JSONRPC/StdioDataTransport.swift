//
//  StdioDataTransport.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public class StdioDataTransport: DataTransport {
    public let stdinPipe: Pipe
    public let stdoutPipe: Pipe
    public let stderrPipe: Pipe
    var readHandler: ReadHandler?
    
    public init() {
        self.stdinPipe = Pipe()
        self.stdoutPipe = Pipe()
        self.stderrPipe = Pipe()
        self.readHandler = nil
        
        stdoutPipe.fileHandleForReading.readabilityHandler = { [unowned self] handle in
            let data = handle.availableData
            
            guard data.count > 0 else {
                return
            }
            
            self.readHandler?(data)
        }
        
        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            
            guard data.count > 0 else {
                return
            }
            
            if let string = String(bytes: data, encoding: .utf8) {
                print("stderr: \(string)")
            }
        }
    }
    
    public func write(_ data: Data) {
        stdinPipe.fileHandleForWriting.write(data)
    }
    
    public func setReaderHandler(_ handler: @escaping (Data) -> Void) {
        self.readHandler = handler
    }
}
