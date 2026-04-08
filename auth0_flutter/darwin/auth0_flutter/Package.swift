// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "auth0_flutter",
    platforms: [
        .iOS("14.0"),
        .macOS("11.0"),
    ],
    products: [
        .library(name: "auth0-flutter", targets: ["auth0_flutter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/auth0/Auth0.swift", exact: "2.18.0"),
        .package(url: "https://github.com/auth0/JWTDecode.swift", exact: "3.3.0"),
        .package(url: "https://github.com/auth0/SimpleKeychain", exact: "1.3.0"),
    ],
    targets: [
        .target(
            name: "auth0_flutter",
            dependencies: [
                .product(name: "Auth0", package: "Auth0.swift"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "SimpleKeychain", package: "SimpleKeychain"),
            ],
            path: "Sources/auth0_flutter"
        ),
    ]
)
