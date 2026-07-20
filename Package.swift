// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoulSpeak",
    platforms: [
        .iOS(.v17)
    ],
    products: [],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SoulSpeak",
            dependencies: [],
            path: "SoulSpeak",
            resources: [
                .process("Assets.xcassets"),
                .process("Resources"),
            ]
        ),
    ]
)
