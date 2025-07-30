// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "AutoLayout",
    platforms: [
        .iOS(.v14),
        .macCatalyst(.v14),
        .macOS(.v12),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "AutoLayout", type: .static, targets: ["AutoLayout"]),
        .library(name: "AutoLayoutDynamic", type: .dynamic, targets: ["AutoLayout"])
    ],
    dependencies: [
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "AutoLayout",
            dependencies: [],
            path: "Sources/Main"
        )
    ]
)
