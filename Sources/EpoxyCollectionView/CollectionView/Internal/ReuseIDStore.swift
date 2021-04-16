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

  /// Generates and returns a new reuse identifier if the given view differentiator has not been
  /// previously registered as determined by its equality, else returns its existing reuse
  /// identifier.
  public func reuseID(byRegistering viewDifferentiator: ViewDifferentiator) -> String {
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

  /// Attempts to retrieve a previously generated reuse identifier for the given view differentiator
  /// if it has been previously registered, else asserts and attempts to return a fallback reuse
  /// identifier for a view of the same type if one could not be found, otherwise returns `nil`.
  public func registeredReuseID(for viewDifferentiator: ViewDifferentiator) -> String? {
    if let existingReuseID = reuseIDsForViewDifferentiators[viewDifferentiator] {
      return existingReuseID
    }

    EpoxyLogger.shared.assertionFailure(
      """
      Unable to locate a reuse ID for \(viewDifferentiator.viewTypeDescription) with styleID \
      \(viewDifferentiator.styleID?.base as Any) as it has an unstable implementation of Hashable. \
      This is likely due to a styleID type with unstable comparability, e.g. a Style class that is \
      mutated _after_ being set on a view, causing it to be unequal to the styleID that was \
      originally registered. Attempting to dequeue another view of the same type. This is \
      programmer error.
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
