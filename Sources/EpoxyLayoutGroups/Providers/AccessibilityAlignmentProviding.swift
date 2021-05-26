// Created by Tyler Hedrick on 3/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - AccessibilityAlignmentProviding

/// Describes something that can provide an `accessibilityAlignment`
public protocol AccessibilityAlignmentProviding {
  /// The accessibilityAlignment for an item in an `HGroup`. This is applied
  /// when an `HGroup` is using its accessibility layout which by default happens
  /// when the `preferredContentSizeCategory.isAccessibilityCategory` is `true`.
  /// That accessibility layout essentially converts the `HGroup` into a `VGroup` and
  /// uses the provided `accessibilityAlignment` value for each item to determine the layout.
  /// The default value of this property is `nil`.
  var accessibilityAlignment: VGroup.ItemAlignment? { get }
}

// MARK: - EpoxyModeled + AccessibilityAlignmentProviding

extension EpoxyModeled where Self: AccessibilityAlignmentProviding {

  // MARK: Public

  /// The accessibilityAlignment value for this model
  public var accessibilityAlignment: VGroup.ItemAlignment? {
    get { self[accessibilityAlignmentProperty] }
    set { self[accessibilityAlignmentProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `accessibiltyAlignment` value
  /// with the one provided.
  public func accessibilityAlignment(_ value: VGroup.ItemAlignment?) -> Self {
    copy(updating: accessibilityAlignmentProperty, to: value)
  }

  // MARK: Private

  private var accessibilityAlignmentProperty: EpoxyModelProperty<VGroup.ItemAlignment?> {
    .init(keyPath: \Self.accessibilityAlignment, defaultValue: nil, updateStrategy: .replace)
  }
}
