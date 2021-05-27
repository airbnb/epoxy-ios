// Created by Tyler Hedrick on 3/25/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - GroupItemsProviding

/// Describes something that can provide an array of group items.
public protocol GroupItemsProviding {
  /// The set of group items handled by a group.
  var groupItems: [GroupItemModeling] { get }
}

// MARK: - EpoxyModeled + GroupItemsProviding

extension EpoxyModeled where Self: GroupItemsProviding {

  // MARK: Public

  /// The set of group items handled by a group.
  public var groupItems: [GroupItemModeling] {
    get { self[groupItemsProperty] }
    set { self[groupItemsProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `groupItems` value
  /// with the one provided.
  public func groupItems(_ value: [GroupItemModeling]) -> Self {
    copy(updating: groupItemsProperty, to: value)
  }

  // MARK: Private

  private var groupItemsProperty: EpoxyModelProperty<[GroupItemModeling]> {
    .init(keyPath: \GroupItemsProviding.groupItems, defaultValue: [], updateStrategy: .replace)
  }
}
