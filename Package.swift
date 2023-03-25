// swift-tools-version:5.7
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
        .library(name: "AutoLayout", type: .dynamic, targets: ["AutoLayout"]),
        .library(name: "AutoLayoutStatic", type: .static, targets: ["AutoLayout"])
    ],
    dependencies: [
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AutoLayout",
            dependencies: [],
            path: "sources/main"
        )
    ]
)
