# SwiftLSPClient

[![Build Status](https://travis-ci.org/ChimeHQ/SwiftLSPClient.svg?branch=master)](https://travis-ci.org/ChimeHQ/SwiftLSPClient)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This is a Swift library for interacting with [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) implementations.

An LSP server provides rich information about source code. An LSP client consumes this information. This library is all about the client side.

## Example

```swift
import SwiftLSPClient

let executablePath = "path/to/your/executable-lsp-server"
let host = LanguageServerProcessHost(path: executablePath, arguments: [])

host.start { (server) in
    guard let server = server else {
        Swift.print("unable to launch server")
        return
    }

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

The LSP [specification](https://microsoft.github.io/language-server-protocol/specification_) is large, and this library currently does not implement it all. Initialization, text synchronization, hover, and completions are supported. Additionally, the types defined should work correctly for servers that are written to a spec older than the current version (3.0).

## Installation

SwiftLSPClient uses [Carthage](https://github.com/Carthage/Carthage) for its dependencies, so it's a perfect fit for projects that also use that system.

### Carthage

```
github "ChimeHQ/SwiftLSPClient"
```

### Building

The project is being developed with Xcode 10.1 running on macOS 10.14 Mojave. After a checkout, you can install the dependencies with carthage.

```
carthage update --platform macOS
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
