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
