//
//  Methods.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public struct ProtocolMethod {
    public static let Initialize = "initialize"
    public static let Initialized = "initialized"
    
    public struct Window {
        public static let LogMessage = "window/logMessage"
    }
    
    public struct TextDocument {
        public static let Hover = "textDocument/hover"
        public static let Completion = "textDocument/completion"
        public static let DidOpen = "textDocument/didOpen"
        public static let DidChange = "textDocument/didChange"
        public static let WillSave = "textDocument/willSave"
        public static let WillSaveWaitUntil = "textDocument/willSaveWaitUntil"
        public static let DidSave = "textDocument/didSave"
        public static let DidClose = "textDocument/didClose"
    }
    
    public struct CompletionItem {
        public static let Resolve = "completionItem/resolve"
    }
}
