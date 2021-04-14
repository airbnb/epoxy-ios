// Created by Tyler Hedrick on 4/7/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - ReflowsForAccessibilityTypeSizeProviding

/// Describes something that provides a `reflowsForAccessibilityTypeSizes` flag
public protocol ReflowsForAccessibilityTypeSizeProviding {
  /// Only used in HGroup. Whether or not the HGroup should reflow for accessibility
  /// type sizes. When this value is `true` the `HGroup` will reflow when
  /// `preferredContentSizeCategory.isAccessibilityCategory` is `true`. The `HGroup` reflows
  /// to model a `VGroup` and uses the `accessibiltyAlignment` value to determine item alignments.
  var reflowsForAccessibilityTypeSizes: Bool { get }
}

// MARK: - CallbackContextEpoxyModeled

extension EpoxyModeled where Self: ReflowsForAccessibilityTypeSizeProviding {

  // MARK: Public

  /// The `reflowsForAccessibilityTypeSizes` value for this model
  public var reflowsForAccessibilityTypeSizes: Bool {
    get { self[reflowsForAccessibilityTypeSizeProperty] }
    set { self[reflowsForAccessibilityTypeSizeProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `reflowsForAccessibilityTypeSizes` value
  /// with the one provided.
  public func reflowsForAccessibilityTypeSizes(_ value: Bool) -> Self {
    copy(updating: reflowsForAccessibilityTypeSizeProperty, to: value)
  }

  // MARK: Private

  private var reflowsForAccessibilityTypeSizeProperty: EpoxyModelProperty<Bool> {
    .init(keyPath: \Self.reflowsForAccessibilityTypeSizes, defaultValue: true, updateStrategy: .replace)
  }
}
