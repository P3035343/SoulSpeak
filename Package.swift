// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoulSpeak",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SoulSpeak",
            targets: ["SoulSpeak"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SoulSpeak",
            dependencies: [],
            path: "Sources/SoulSpeak",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SoulSpeakTests",
            dependencies: ["SoulSpeak"],
            path: "Tests/SoulSpeakTests"
        ),
    ]
)
