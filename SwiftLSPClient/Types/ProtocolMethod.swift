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
        public static let ShowMessage = "window/showMessage"
        public static let ShowMessageRequest = "window/showMessageRequest"
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
        public static let SignatureHelp = "textDocument/signatureHelp"
        public static let Declaration = "textDocument/declaration"
        public static let Definition = "textDocument/definition"
        public static let TypeDefinition = "textDocument/typeDefinition"
        public static let Implementation = "textDocument/implementation"
        public static let DocumentSymbol = "textDocument/documentSymbol"
        public static let Formatting = "textDocument/formatting"
        public static let RangeFormatting = "textDocument/rangeFormatting"
        public static let OnTypeFormatting = "textDocument/onTypeFormatting"
        public static let PublishDiagnostics = "textDocument/publishDiagnostics"
    }
    
    public struct CompletionItem {
        public static let Resolve = "completionItem/resolve"
    }

    public struct Workspace {
        public static let WorkspaceFolders = "workspace/workspaceFolders"
    }
}
