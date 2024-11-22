// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "events",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        .library(name: "Events", targets: ["Events"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.104.0"),
    ],
    targets: [
        .target(
            name: "Events",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableExperimentalFeature("StrictConcurrency=complete"),
            ]
        ),
        .testTarget(
            name: "EventsTests",
            dependencies: [
                "Events",
                .product(name: "XCTVapor", package: "vapor"),
            ]),
    ]
)
