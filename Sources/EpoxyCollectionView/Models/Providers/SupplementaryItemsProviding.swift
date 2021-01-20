// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - SupplementaryItemsProviding

public protocol SupplementaryItemsProviding {
  /// The supplementary items with in a collection view, with a key of the element kind and a value
  /// of the models of that specific kind.
  typealias SupplementaryItems = [String: [SupplementaryItemModeling]]

  /// The supplementary items with in a collection view.
  var supplementaryItems: SupplementaryItems { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: SupplementaryItemsProviding {

  // MARK: Public

  public var supplementaryItems: SupplementaryItems {
    get { self[supplementaryItemsProperty] }
    set { self[supplementaryItemsProperty] = newValue }
  }

  /// Returns a copy of this model with the current `supplementaryItems` value replaced with the
  /// provided `value`.
  public func supplementaryItems(_ value: SupplementaryItems) -> Self {
    copy(updating: supplementaryItemsProperty, to: value)
  }

  /// Returns a copy of this model with the `supplementaryItems` of the given `elementKind` replaced
  /// with the provided `value`.
  public func supplementaryItems(
    ofKind elementKind: String,
    _ value: [SupplementaryItemModeling]?)
    -> Self
  {
    var copy = self
    copy.supplementaryItems[elementKind] = value
    return copy
  }

  // MARK: Private

  private var supplementaryItemsProperty: EpoxyModelProperty<SupplementaryItems> {
    .init(
      keyPath: \SupplementaryItemsProviding.supplementaryItems,
      defaultValue: [:],
      updateStrategy: .replace)
  }
}
