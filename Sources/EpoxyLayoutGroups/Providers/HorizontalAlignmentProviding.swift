// Created by Tyler Hedrick on 3/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - HorizontalAlignmentProviding

/// Describes something that provides a `horizontalAlignment`
public protocol HorizontalAlignmentProviding {
  /// Horizontal alignments are used in `VGroup` to specify the default
  /// horizontal alignment of the items contained in that group. You can
  /// also specify `horizontalAlignments` on a per item basis which will
  /// take precedence over the value for the group.
  var horizontalAlignment: VGroup.ItemAlignment? { get }
}

// MARK: - CallbackContextEpoxyModeled

extension EpoxyModeled where Self: HorizontalAlignmentProviding {

  // MARK: Public

  /// The `horizontalAlignment` value for this model
  public var horizontalAlignment: VGroup.ItemAlignment? {
    get { self[horizontalAlignmentProperty] }
    set { self[horizontalAlignmentProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `horizontalAlignment` value
  /// with the one provided.
  public func horizontalAlignment(_ value: VGroup.ItemAlignment?) -> Self {
    copy(updating: horizontalAlignmentProperty, to: value)
  }

  // MARK: Private

  private var horizontalAlignmentProperty: EpoxyModelProperty<VGroup.ItemAlignment?> {
    .init(keyPath: \HorizontalAlignmentProviding.horizontalAlignment, defaultValue: nil, updateStrategy: .replace)
  }
}
