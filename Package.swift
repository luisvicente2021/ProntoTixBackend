// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProntoTixBackend",

    platforms: [
        .macOS(.v13)
    ],

    products: [
        .executable(
            name: "ProntoTixBackend",
            targets: ["ProntoTixBackend"]
        )
    ],

    dependencies: [
        .package(
            url: "https://github.com/vapor/vapor.git",
            exact: "4.117.0"
        ),

        .package(
            url: "https://github.com/vapor/fluent.git",
            from: "4.0.0"
        ),

        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            exact: "2.9.2"
        ),

        .package(
            url: "https://github.com/vapor/jwt.git",
            from: "4.2.2"
        )
    ],

    targets: [
        .executableTarget(
            name: "ProntoTixBackend",
            dependencies: [
                .product(
                    name: "Vapor",
                    package: "vapor"
                ),

                .product(
                    name: "Fluent",
                    package: "fluent"
                ),

                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),

                .product(
                    name: "JWT",
                    package: "jwt"
                )
            ]
        )
    ]
)