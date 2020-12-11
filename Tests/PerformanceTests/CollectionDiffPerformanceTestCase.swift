// Created by eric_horacek on 12/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import XCTest

extension Int: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? Int else {
      return false
    }
    return self == other
  }

  public var diffIdentifier: AnyHashable {
    self
  }
}

struct TestSection: DiffableSection {
  var diffIdentifier: AnyHashable
  var diffableItems: [Int]

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? TestSection else {
      return false
    }
    return self.diffIdentifier == other.diffIdentifier
  }
}

final class CollectionDiffPerformanceTestCase: XCTestCase {

  func testMeasureMakeChangeset() {
    let source = Array(1...100_000)

    var generator = SeededRandomNumberGenerator(seed: 0)
    let target = Array(10_000...110_000).shuffled(using: &generator)

    measure {
      _ = source.makeChangeset(from: target)
    }
  }

  func testMeasureMakeSectionedChangeset() {
    let source: [TestSection] = (0...10).map { index in
      let items = Array((index * 1_000)...((index + 1) * 1_000))
      return TestSection(diffIdentifier: index, diffableItems: items)
    }

    var generator = SeededRandomNumberGenerator(seed: 0)
    let target: [TestSection] = (1...11).map { index in
      let items = Array((index * 1_100)...((index + 1) * 1_100)).shuffled(using: &generator)
      return TestSection(diffIdentifier: index, diffableItems: items)
    }.shuffled(using: &generator)

    measure {
      _ = source.makeSectionedChangeset(from: target)
    }
  }

}

// MARK: - SeededRandomNumberGenerator

import class GameplayKit.GKMersenneTwisterRandomSource

// Adapted from https://stackoverflow.com/a/57370987/4076325
private struct SeededRandomNumberGenerator: RandomNumberGenerator {

  init(seed: UInt64) {
    generator = GKMersenneTwisterRandomSource(seed: seed)
  }

  mutating func next() -> UInt64 {
    // GKRandom produces values in [INT32_MIN, INT32_MAX] range; hence we need two numbers to
    // produce 64-bit value.
    let next1 = UInt64(bitPattern: Int64(generator.nextInt()))
    let next2 = UInt64(bitPattern: Int64(generator.nextInt()))
    return next1 ^ (next2 << 32)
  }

  private let generator: GKMersenneTwisterRandomSource

}
