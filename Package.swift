import PackageDescription

let package = Package(
    name: "BlueJet",
    dependencies: [
        .Package(url: "https://github.com/agisboye/CLMDB.git", majorVersion: 0, minor: 1)
    ]
)
