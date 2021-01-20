// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - SelectionStyleProviding

public protocol SelectionStyleProviding {
  /// The selection style of the cell.
  ///
  /// If `nil`, defaults to the `selectionStyle` set of the `CollectionView`.
  var selectionStyle: ItemSelectionStyle? { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: SelectionStyleProviding {

  // MARK: Public

  public var selectionStyle: ItemSelectionStyle? {
    get { self[selectionStyleProperty] }
    set { self[selectionStyleProperty] = newValue }
  }

  /// Returns a copy of this model with the selection style replaced with the provided `value`.
  public func selectionStyle(_ value: ItemSelectionStyle?) -> Self {
    copy(updating: selectionStyleProperty, to: value)
  }

  // MARK: Private

  private var selectionStyleProperty: EpoxyModelProperty<ItemSelectionStyle?> {
    .init(
      keyPath: \SelectionStyleProviding.selectionStyle,
      defaultValue: nil,
      updateStrategy: .replace)
  }
}
