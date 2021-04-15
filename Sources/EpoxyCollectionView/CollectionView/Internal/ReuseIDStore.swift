// Created by Bryan Keller on 7/16/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - ReuseIDStore

/// Handles the creation of reuse identifiers for use with `CollectionView` by tracking which view
/// type + view differentiator combinations have been seen so far, and generating a new reuse
/// identifier whenever a new combination is encountered.
///
/// For example, if we encounter a `TitleRow` with a style ID of `{ font: .black }`, then we encounter another
/// `TitleRow` with a style ID of `{ font: .green }`, then we encounter one last `TitleRow` with a style ID of
/// `{ font: .black }`, 2 reuse identifiers are created:
/// 1. `"TitleRow_0"` (for `TitleRow` + `{ font: .black }`)
/// 2. `"TitleRow_1"` (for `TitleRow` + `{ font: .green }`)
///
public final class ReuseIDStore {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  /// Vends a new reuse identifier string for the given `ViewDifferentiator`, generating a new reuse
  /// identifier whenever a new `viewDifferentiator` is encountered as determined by its equality.
  public func registerReuseID(for viewDifferentiator: ViewDifferentiator) -> String {
    if let existingReuseID = reuseIDsForViewDifferentiators[viewDifferentiator] {
      return existingReuseID
    }

    let viewType = viewDifferentiator.viewTypeDescription
    let uniqueViewDifferentiatorCount = uniqueViewDifferentiatorCountsForViewTypes[viewType] ?? 0
    uniqueViewDifferentiatorCountsForViewTypes[viewType] = uniqueViewDifferentiatorCount + 1

    let reuseID = "\(viewType)_\(uniqueViewDifferentiatorCount)"
    reuseIDsForViewDifferentiators[viewDifferentiator] = reuseID
    return reuseID
  }

  /// Attempts to dequeue a reuse identifier string for the given `ViewDifferentiator`.
  public func dequeueReuseID(for viewDifferentiator: ViewDifferentiator) -> String? {
    if let existingReuseID = reuseIDsForViewDifferentiators[viewDifferentiator] {
      return existingReuseID
    }

    // We're attempting to dequeue a reuse ID for a `ViewDifferentiator` that doesn't exist in . This
    // is probably due to an `ViewDifferentiator.styleID` instance that an has unstable hash value,
    // e.g. a `Hashable` `class` that is mutated _after_ being set on a component, giving it a new
    // hash value.
    EpoxyLogger.shared.assertionFailure(
      """
      Unable to dequeue reuse ID for \(viewDifferentiator.viewTypeDescription) styleID \
      \(viewDifferentiator.styleID?.base as Any) as it has an unstable implementation of \
      `Hashable`. This is likely due to an `styleID` instance that an has unstable hash value, \
      e.g. a `Hashable` `class` that is mutated _after_ being set on a view, causing it to be \
      unequal to the `styleID` that was originally registered. Attempting to dequeue another view \
      of the same type. This is programmer error.
      """)

    return reuseIDsForViewDifferentiators
      .filter { $0.key.viewTypeDescription == viewDifferentiator.viewTypeDescription }
      .sorted(by: { $0.value < $1.value })
      // Take the first item so it's stable over time in case more items are added later.
      .first?
      .value
  }

  // MARK: Private

  private var uniqueViewDifferentiatorCountsForViewTypes = [String: Int]()
  private var reuseIDsForViewDifferentiators = [ViewDifferentiator: String]()
}
