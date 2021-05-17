// Created by Tyler Hedrick on 3/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - VerticalAlignmentProviding

/// Describes something that provides vertical alignment
public protocol VerticalAlignmentProviding {
  /// Vertical alignments are used in `HGroup` to specify the default
  /// vertical alignment of the items contained in that group. You can
  /// also specify `verticalAlignment` on a per item basis which will
  /// take precedence over the value for the group.
  var verticalAlignment: HGroup.ItemAlignment? { get }
}

// MARK: - CallbackContextEpoxyModeled

extension EpoxyModeled where Self: VerticalAlignmentProviding {

  // MARK: Public

  /// The `verticalAlignment` value for this model
  public var verticalAlignment: HGroup.ItemAlignment? {
    get { self[verticalAlignmentProperty] }
    set { self[verticalAlignmentProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `verticalAlignment` value
  /// with the one provided.
  public func verticalAlignment(_ value: HGroup.ItemAlignment?) -> Self {
    copy(updating: verticalAlignmentProperty, to: value)
  }

  // MARK: Private

  private var verticalAlignmentProperty: EpoxyModelProperty<HGroup.ItemAlignment?> {
    .init(keyPath: \Self.verticalAlignment, defaultValue: nil, updateStrategy: .replace)
  }
}
