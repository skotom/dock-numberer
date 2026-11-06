// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DockNumberer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "DockNumberer", path: "Sources/DockNumberer")
    ]
)
