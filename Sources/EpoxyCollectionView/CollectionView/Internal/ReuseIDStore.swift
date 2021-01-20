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
  public func reuseID(for viewDifferentiator: ViewDifferentiator) -> String {
    if let existingReuseID = reuseIDsForViewDifferentiators[viewDifferentiator] {
      return existingReuseID
    } else {
      let viewType = viewDifferentiator.viewTypeDescription
      let uniqueViewDifferentiatorCount = uniqueViewDifferentiatorCountsForViewTypes[viewType] ?? 0
      uniqueViewDifferentiatorCountsForViewTypes[viewType] = uniqueViewDifferentiatorCount + 1

      let reuseID = "\(viewType)_\(uniqueViewDifferentiatorCount)"
      reuseIDsForViewDifferentiators[viewDifferentiator] = reuseID
      return reuseID
    }
  }

  // MARK: Private

  private var uniqueViewDifferentiatorCountsForViewTypes = [String: Int]()
  private var reuseIDsForViewDifferentiators = [ViewDifferentiator: String]()
}
