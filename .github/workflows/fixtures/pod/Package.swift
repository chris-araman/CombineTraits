// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pod_fixture",
    products: [
        .executable(
            name: "pod_use_frameworks",
            targets: ["pod_use_frameworks"]),
        .executable(
            name: "pod_use_modular_headers",
            targets: ["pod_use_modular_headers"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "pod_use_frameworks"),
        .target(name: "pod_use_modular_headers"),
    ]
)
