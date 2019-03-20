# BlueJet [![Build Status](https://travis-ci.org/bobek-balinek/BlueJet.svg?branch=master)](https://travis-ci.org/bobek-balinek/BlueJet)

> Blue jet is a rare type of a lightning with a very blue colour with near-ultraviolet emission lines from neutral and ionized molecular nitrogen. It typically occurs in the lower levels of ionosphere at ~50km above the surface of the earth.

### WARNING: This tool is under development and is not ready for production use

## Synopsis

BlueJet is a modern Swift/Cocoa wrapper around Lightning Memory-Mapped Database Manager (LMDB). It fully utilises the multi-threaded access, transations and provides a simple enumeration interface for fetching subsets of the database. Key/Value pairs are using Swift's Encoder/Decoder protocol when dealing with the data.

## What is LMDB?

LMDB is an incredibly fast key-value store written by Howard Chu for the OpenLDAP project. Given the nature of LDAP workloads the design of LMDB is read-optimised (but writes are super fast too!). This particular database allows for multiple databases within one environment which makes separating different data sets much easier to handle. It also allows for multiple processes to access a single database without locking it and supports transactions for making series of fail-safe reads/write routines. For more details on the design and implementation of LMDB go to [the website](https://symas.com/lightning-memory-mapped-database/).

### Value Type oriented

With many data persistence options available for both Cocoa (Touch) and Server-side Swift BlueJet aims to be the simplest and fast Value Type store without the complexity of confusing query language, sub-classing your data models or large set of dependencies. This framework is designed to take any Swift's value type such as String, Int, Float and Data but also provide set of protocols to allow for custom type-to-Data conversion.

### Codable support

You can serialize your custom value types using Swift's Codable protocol. BlueJet will use `JSONEncoder/Decoder` as the default serialization method. You can provide a different method by passing encoder/decoder to respective methods for retrieving/persisting values.

```swift
struct Book: Codable {
    let title: String
    let isbn: String
}

// …

let book = Book(title: "Summary: Astrophysics for People In A Hurry", isbn: "978-1974241422")

transaction.set(value: book, forKey: "Favourite Book")
```

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

BlueJet is designed for Key/Value persistence. Keys and Values can be any of the Swift types i.e. `Int`, `String`, `Double` etc. Additionally, you can persist custom keys and values using the `Codable` protocol. First, you need to initialize the environment for interacting with a set of databases.

```swift
let env = Environment(url: localPath)
let db = env.database(name: "Books")

db.write { trx in
    trx.put(value: "Astrophysics for People In A Hurry", forKey: "Favourite Book")
}

print(db.keys())
```

### Retrieving data

Reading data from the database is very simple:

```swift
let val = db.value(String.self, forKey: "User Name")

print(val)

// "Bobby"
```

### Persiting data

Persistence happens within a transaction. Transactions make it safe to perform a series of operations without corrupting any of the data. To write data to a database use the `write` method like so:

```swift
let num = 42
db.write { (trx: Transaction) in
    trx.set(value: num, forKey: "T-rex")
}
```

### Range enumeration

If you want to iterate over a range of keys you can create a `Range` or `ClosedRange` providing lower and upper bounds to restrict the query. These types conform to Swift's `Collection` type so you can iterate over them usign a `for` loop or the `forEach` method.

### Storable protocol

It is possible to store custom types directly by conforming the type to `Storable` protocol. This protocol requires a function `primaryKey` to return a String representing the key it should be persisted under.

```swift
struct Book: Codable {
    let title: String
    let isbn: String
}

extension Book: Storable {
    func primaryKey(): String {
        return isbn
    }
}

// …

let book = Book(title: "Astrophysics for People In A Hurry", isbn: "978-1974241422")

transaction.set(value: book)

```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Code of Conduct](https://github.com/bobek-balinek/BlueJet/blob/master/CODE_OF_CONDUCT.md).

## License
`BlueJet` is available under the MIT license. See the LICENSE files for more info.
