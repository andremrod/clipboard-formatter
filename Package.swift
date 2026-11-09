// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardFormatter",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ClipboardFormatter", targets: ["ClipboardFormatter"]),
    ],
    targets: [
        .executableTarget(
            name: "ClipboardFormatter",
            path: "Sources/ClipboardFormatter"
        ),
    ]
)
