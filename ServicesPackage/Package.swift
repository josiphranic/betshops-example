// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServicesPackage",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ServicesPackage",
            targets: ["ServicesPackage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxAlamofire.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxCoreLocation.git", .upToNextMajor(from: "1.5.1")),
        .package(name: "RxFeedback", url: "https://github.com/NoTests/RxFeedback.swift.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxReachability", .upToNextMajor(from: "1.2.1")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ServicesPackage",
            dependencies: ["RxAlamofire",
                           "RxSwift",
                           "RxReachability",
                           "RxCoreLocation",
                           "RxFeedback",
                           .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "ServicesPackageTests",
            dependencies: ["ServicesPackage"]),
    ]
)
