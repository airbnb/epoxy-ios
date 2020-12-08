// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - ItemsProviding

public protocol ItemsProviding {
  /// The array of items in a section, typically within the context of a `CollectionView`.
  var items: [ItemModeling] { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: ItemsProviding {

  // MARK: Public

  public var items: [ItemModeling] {
    get { self[itemsProperty] }
    set { self[itemsProperty] = newValue }
  }

  /// Returns a copy of this model with the current `items` value replaced with the provided
  /// `value`.
  public func items(_ value: [ItemModeling]) -> Self {
    copy(updating: itemsProperty, to: value)
  }

  // MARK: Private

  private var itemsProperty: EpoxyModelProperty<[ItemModeling]> {
    .init(keyPath: \ItemsProviding.items, defaultValue: [], updateStrategy: .replace)
  }
}
