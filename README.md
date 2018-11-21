# SwiftLSPClient
This is a Swift library for interacting with [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) implementations.

An LSP server provides rich information about source code. An LSP client consumes this information. This library is all about the client side.

## Example

```swift
import SwiftLSPClient

let transport = StdioDataTransport()

let server = JSONRPCLanguageServer(dataTransport: transport)

let processId = Int(ProcessInfo.processInfo.processIdentifier)
let capabilities = clientCapabilities

let params = InitalizeParams(processId: processId,
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
```

## Supported Features

The LSP [specification](https://microsoft.github.io/language-server-protocol/specification_) is large, and this library currently does not implement it all. Initialization, text synchronization, hover, and completions are supported. Additionally, the types defined should work correctly for servers that are written to a spec older than the current version (3.0).

## Installation

SwiftLSPClient uses [Carthage](https://github.com/Carthage/Carthage) for its dependencies, so it's a perfect fit for projects that also use that system.

### Carthage

```
github "ChimeHQ/SwiftLSPClient"
```

### Contributing

We'd be thrilled to hear about changes you'd like to make. Just open up an issue describing what you'd like to do.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.