[![Github CI](https://github.com/ChimeHQ/SwiftLSPClient/workflows/CI/badge.svg)](https://github.com/ChimeHQ/SwiftLSPClient/actions)

# SwiftLSPClient

⚠️ Heads up!

SwiftLSPClient has been replaced. It was split into two seperate parts. Protocol-level support lives in [LanguageServerProtocol](https://github.com/ChimeHQ/LanguageServerProtocol). Higher-level client abstractions live in [LanguageClient](https://github.com/ChimeHQ/LanguageClient), which is probably what you want.

This is a (now deprecated) Swift library for interacting with [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) implementations.

An LSP server provides rich information about source code. An LSP client consumes this information. This library is all about the client side. It is low-level, and provides only the core abstractions around the types and messages passed between a client and server.

## Example

```swift
import SwiftLSPClient

let executablePath = "path/to/your/lsp-server-executable"
let host = LanguageServerProcessHost(path: executablePath, arguments: [],
    environment: [/* the environment your lsp server requires e.g. PATH */])

host.start { (server) in
    guard let server = server else {
        Swift.print("unable to launch server")
        return
    }
    
    // Set-up notificationResponder to see log/error messages from LSP server
    server.notificationResponder = <object conforming to NotificationResponder>

    let processId = Int(ProcessInfo.processInfo.processIdentifier)
    let capabilities = ClientCapabilities(workspace: nil, textDocument: nil, experimental: nil)

    let params = InitializeParams(processId: processId,
                                  rootPath: nil,
                                  rootURI: nil,
                                  initializationOptions: nil,
                                  capabilities: capabilities,
                                  trace: Tracing.off,
                                  workspaceFolders: nil)

    server.initialize(params: params, block: { (result) in
        switch result {
        case .failure(let error):
            Swift.print("unable to initialize \(error)")
        case .success(let value):
            Swift.print("initialized \(value)")
        }
    })
}
```

## Supported Features

The LSP [specification](https://microsoft.github.io/language-server-protocol/specification) is large, and this library currently does not implement it all. The intention is to support the 3.x specification, but be as backwards-compatible as possible with pre-3.0 servers. 

| Feature            | Supported |
| -------------------|:---------:|
| window/showMessage | ✅ |
| window/showMessageRequest | ✅ |
| window/showDocument | - |
| window/logMessage | ✅ |
| window/workDoneProgress/create | - |
| window/workDoneProgress/cancel | - |
| $/cancelRequest | - |
| $/progress | - |
| initialize | ✅ |
| shutdown | - |
| exit | - |
| telemetry/event | - |
| $/logTrace | - |
| $/setTrace | - |
| client/registerCapability | ✅ |
| client/unregisterCapability | ✅ |
| workspace/workspaceFolders | - |
| workspace/didChangeWorkspaceFolders | - |
| workspace/didChangeConfiguration | - |
| workspace/configuration | ✅ |
| workspace/didChangeWatchedFiles | - |
| workspace/symbol | - |
| workspace/executeCommand | - |
| workspace/applyEdit | - |
| workspace/willCreateFiles | - |
| workspace/didCreateFiles | - |
| workspace/willRenameFiles | - |
| workspace/didRenameFiles | - |
| workspace/willDeleteFiles | - |
| workspace/didDeleteFiles | - |
| textDocument/didOpen | ✅ |
| textDocument/didChange | ✅ |
| textDocument/willSave | ✅ |
| textDocument/willSaveWaitUntil | ✅ |
| textDocument/didSave | ✅ |
| textDocument/didClose | ✅ |
| textDocument/publishDiagnostics | ✅ |
| textDocument/completion | ✅ |
| completionItem/resolve | - |
| textDocument/hover | ✅ |
| textDocument/signatureHelp | ✅ |
| textDocument/declaration | ✅ |
| textDocument/definition | ✅ |
| textDocument/typeDefinition | ✅ |
| textDocument/implementation | ✅ |
| textDocument/references | ✅  |
| textDocument/documentHighlight | - |
| textDocument/documentSymbol | ✅ |
| textDocument/codeAction | ✅ |
| codeLens/resolve | - |
| textDocument/codeLens | - |
| workspace/codeLens/refresh | - |
| textDocument/documentLink | - |
| documentLink/resolve | - |
| textDocument/documentColor | - |
| textDocument/colorPresentation | - |
| textDocument/formatting | ✅ |
| textDocument/rangeFormatting | ✅ |
| textDocument/onTypeFormatting | ✅ |
| textDocument/rename | ✅ |
| textDocument/prepareRename | ✅ |
| textDocument/foldingRange | ✅ |
| textDocument/selectionRange | - |
| textDocument/prepareCallHierarchy | - |
| textDocument/prepareCallHierarchy | - |
| callHierarchy/incomingCalls | - |
| callHierarchy/outgoingCalls | - |
| textDocument/semanticTokens/full | ✅ |
| textDocument/semanticTokens/full/delta | ✅ |
| textDocument/semanticTokens/range | ✅ |
| workspace/semanticTokens/refresh | ✅ |
| textDocument/linkedEditingRange | - |
| textDocument/moniker | - |

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/SwiftLSPClient")
]
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via an issue or pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
