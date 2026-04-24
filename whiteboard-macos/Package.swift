// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Whiteboard",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Whiteboard", targets: ["Whiteboard"]),
        .library(name: "WhiteboardCore", targets: ["WhiteboardCore"]),
    ],
    targets: [
        .target(
            name: "WhiteboardCore",
            path: "Sources/WhiteboardCore"
        ),
        .executableTarget(
            name: "Whiteboard",
            dependencies: ["WhiteboardCore"],
            path: "Sources/Whiteboard",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "WhiteboardCoreTests",
            dependencies: ["WhiteboardCore"],
            path: "Tests/WhiteboardCoreTests"
        ),
    ]
)
