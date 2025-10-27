// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VoiceTranslator",
    platforms: [
        .iOS(.v15) // Required for Translation framework
    ],
    products: [
        .library(
            name: "VoiceTranslator",
            targets: ["VoiceTranslator"]),
    ],
    dependencies: [
        // No external dependencies needed - using Apple's built-in frameworks
    ],
    targets: [
        .target(
            name: "VoiceTranslator",
            dependencies: []),
        .testTarget(
            name: "VoiceTranslatorTests",
            dependencies: ["VoiceTranslator"]),
    ]
)
