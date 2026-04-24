// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Whiteboard",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Whiteboard", targets: ["Whiteboard"])
    ],
    targets: [
        .executableTarget(
            name: "Whiteboard",
            path: "Sources/Whiteboard",
            resources: [.process("Resources")]
        )
    ]
)
