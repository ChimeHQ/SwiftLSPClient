[![Github CI](https://github.com/ChimeHQ/SwiftLSPClient/workflows/CI/badge.svg)](https://github.com/ChimeHQ/SwiftLSPClient/actions)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftLSPClient.svg)](https://cocoapods.org/)

# SwiftLSPClient

This is a Swift library for interacting with [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) implementations.

An LSP server provides rich information about source code. An LSP client consumes this information. This library is all about the client side.

## Example

```swift
import SwiftLSPClient

let executablePath = "path/to/your/lsp-server-executable"
let host = LanguageServerProcessHost(path: executablePath, arguments: [],
    environemnt: [/* the environment your lsp server requires e.g. PATH */])

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
| window/logMessage | ✅ |
| telemetry/event | - |
| client/registerCapability | - |
| client/unregisterCapability | - |
| workspace/workspaceFolders | - |
| workspace/didChangeWorkspaceFolders | - |
| workspace/didChangeConfiguration | - |
| workspace/configuration | - |
| workspace/didChangeWatchedFiles | - |
| workspace/symbol | - |
| workspace/executeCommand | - |
| workspace/applyEdit | - |
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
| textDocument/codeAction | - |
| textDocument/codeLens | - |
| codeLens/resolve | - |
| textDocument/documentLink | - |
| documentLink/resolve | - |
| textDocument/documentColor | - |
| textDocument/colorPresentation | - |
| textDocument/formatting | ✅ |
| textDocument/rangeFormatting | ✅ |
| textDocument/onTypeFormatting | ✅ |
| textDocument/rename | - |
| textDocument/prepareRename | - |
| textDocument/foldingRange | ✅ |

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/SwiftLSPClient.git")
]
```

### Carthage

```
github "ChimeHQ/SwiftLSPClient"
```

### CocoaPods

```
pod 'SwiftLSPClient'
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
