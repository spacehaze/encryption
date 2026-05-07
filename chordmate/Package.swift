// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Chordmate",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MusicTheory", targets: ["MusicTheory"]),
    ],
    targets: [
        .target(
            name: "MusicTheory",
            path: "Models"
        ),
        .testTarget(
            name: "MusicTheoryTests",
            dependencies: ["MusicTheory"],
            path: "Tests/MusicTheoryTests"
        ),
    ]
)
