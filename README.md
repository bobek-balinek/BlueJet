# BlueJet [![Build Status](https://travis-ci.org/bobek-balinek/BlueJet.svg?branch=master)](https://travis-ci.org/bobek-balinek/BlueJet)

> Blue jet is a rare type of a lightning with a very blue colour with near-ultraviolet emission lines from neutral and ionized molecular nitrogen. It typically occurs in the lower levels of ionosphere at ~50km above the surface of the earth.

## Synopsis

BlueJet is a modern Swift/Cocoa wrapper around Lightning Memory-Mapped Database Manager (LMDB). It fully utilises the multi-threaded access, transations and provides a simple enumeration interface for fetching subsets of the database. Key/Value pairs are using Swift's Encoder/Decoder protocol when dealing with the data.

### Value Type-oriented

With many data persistence options available for both Cocoa (Touch) and Server-side Swift BlueJet aims to be the simplest and fast Value Type store without the complexity of confusing query language, sub-classing your data models or large set of dependencies. This framework is designed to take any Swift's value type such as String, Int, Float and Data but also provide set of protocols to allow for custom type-to-Data conversion.

### Encoder/Decoder support

With the upcoming release of Swift 4, BlueJet will support `struct` encoder/decoder features making it even easier to store any data you use within your app.

## What is LMDB?

LMDB is an incredibly fast key-value store written by Howard Chu for the OpenLDAP project. Given the nature of LDAP workloads the design of LMDB is read-optimised (but writes are super fast too!). This particular database allows for multiple databases within one environment which makes separating different data sets much easier to handle. It also allows for multiple processes to access a single database without locking it and supports transactions for making series of fail-safe reads/write routines. For more details on the design and implementation of LMDB go to [the website](https://symas.com/lightning-memory-mapped-database/).

## Installation

### Carthage

Add BlueJet to your Cartfile:

```
github "bobek-balinek/BlueJet"
```

Then run:

```
carthage update --use-submodules
```

### Swift Package Manager

Add BlueJet as a dependency in your `Package.swift` file and import it in your project:

```swift
import PackageDescription

let package = Package(
    name: "YourGreatNewProject",
    dependencies: [
        .Package(url: "https://github.com/bobek-balinek/BlueJet.git", majorVersion: 0, minor: 1)
    ]
)

```

## Basic Usage

### Data (De)Serialisation

### Getting data

### Storing data

### Enumeration

### Storage protocol

## Documentation

**TODO**

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Code of Conduct](https://github.com/bobek-balinek/BlueJet/blob/master/CODE_OF_CONDUCT.md).

## License
`BlueJet` is available under the MIT license. See the LICENSE files for more info.
