// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLSPClient",
    platforms: [.macOS("10.10")],
    products: [
        .library(name: "SwiftLSPClient", targets: ["SwiftLSPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/JSONRPC", from: "0.1.3"),
    ],
    targets: [
        .target(name: "SwiftLSPClient", dependencies: ["JSONRPC"], path: "SwiftLSPClient/"),
        .testTarget(name: "SwiftLSPClientTests", dependencies: ["SwiftLSPClient"], path: "SwiftLSPClientTests/"),
    ]
)
