// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DockKeys",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "DockKeys", path: "Sources/DockKeys")
    ]
)
