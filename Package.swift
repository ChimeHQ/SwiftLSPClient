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
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
        .package(url: "https://github.com/ChimeHQ/JSONRPC", from: "0.2.1"),
    ],
    targets: [
        .target(name: "SwiftLSPClient", dependencies: ["JSONRPC", "AnyCodable"], path: "SwiftLSPClient/"),
        .testTarget(name: "SwiftLSPClientTests", dependencies: ["SwiftLSPClient"], path: "SwiftLSPClientTests/"),
    ]
)
