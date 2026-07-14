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
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.3.0"),
    ],
    targets: [
        .target(
            name: "SoulSpeak",
            dependencies: [
                "Kingfisher",
                .product(name: "Lottie", package: "lottie-spm"),
            ],
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
