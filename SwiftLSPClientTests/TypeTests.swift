//
//  TypeTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-08.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
import JSONRPC
@testable import SwiftLSPClient

class TypeTests: XCTestCase {
    func testSymbolInformation() {
        let json = """
{"id":2,"result":[{"name":"something","kind":12,"location":{"uri":"file:///hello.go","range":{"start":{"line":19,"character":5},"end":{"line":19,"character":13}}}}],"jsonrpc":"2.0"}
"""
        let data = json.data(using: .utf8)!
        let response = try! JSONDecoder().decode(JSONRPCResponse<DocumentSymbolResponse>.self, from: data)

        let location = Location(uri: "file:///hello.go", range: LSPRange(startPair: (19, 5), endPair: (19, 13)))
        let symbolInfo = SymbolInformation(name: "something", kind: 12, deprecated: nil, location: location, containerName: nil)
        XCTAssertEqual(response.result, DocumentSymbolResponse.symbolInformation([symbolInfo]))
    }

    func testCodeAction() {
        let json = """
{"jsonrpc":"2.0","result":[{"title":"Organize Imports","kind":"source.organizeImports","edit":{"documentChanges":[{"textDocument":{"version":0,"uri":"file:///hello.go"},"edits":[{"range":{"start":{"line":7,"character":0},"end":{"line":7,"character":0}},"newText":"\\t\\"os\\"\\n"}]}]}}],"id":2}
"""
        let data = json.data(using: .utf8)!
        let response = try! JSONDecoder().decode(JSONRPCResponse<CodeActionResponse>.self, from: data)

        let range = LSPRange(startPair: (7, 0), endPair: (7,0))
        let edit = TextDocumentEdit(textDocument: VersionedTextDocumentIdentifier(uri: "file:///hello.go", version: 0),
                                    edits: [TextEdit(range: range, newText: "\t\"os\"\n")])
        let codeAction = CodeAction(title: "Organize Imports",
                                    kind: CodeActionKind.SourceOrganizeImports,
                                    diagnostics: nil,
                                    isPreferred: nil,
                                    edit: WorkspaceEdit(changes: nil, documentChanges: [.textDocumentEdit(edit)]),
                                    command: nil)
        XCTAssertEqual(response.result, CodeActionResponseType.actions([codeAction]))
    }
}
