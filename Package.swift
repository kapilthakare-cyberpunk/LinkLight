// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LinkLight",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "LinkLight", targets: ["LinkLight"])
    ],
    targets: [
        .executableTarget(name: "LinkLight", dependencies: [])
    ]
)
