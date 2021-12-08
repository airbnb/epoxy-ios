// Created by Tyler Hedrick on 4/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - GroupEdgeInsets

public struct GroupEdgeInsets: Hashable {

  // MARK: Lifecycle

  /// Creates a GroupEdgeInsets instance with the provided values
  /// - Parameters:
  ///   - top: a static value for top
  ///   - leading: a static value for leading
  ///   - bottom: a static value for bottom
  ///   - trailing: a static value for trailing
  public init(
    top: CGFloat,
    leading: CGFloat,
    bottom: CGFloat,
    trailing: CGFloat)
  {
    self.top = .fixed(top)
    self.leading = .fixed(leading)
    self.bottom = .fixed(bottom)
    self.trailing = .fixed(trailing)
  }

  /// Creates a GroupEdgeInsets instance with the provided adaptive values
  /// - Parameters:
  ///   - top: an adaptive value for top
  ///   - leading: an adaptive value for leading
  ///   - bottom: an adaptive value for bottom
  ///   - trailing: an adaptive value for trailing
  public init(
    top: AdaptiveFloat,
    leading: AdaptiveFloat,
    bottom: AdaptiveFloat,
    trailing: AdaptiveFloat)
  {
    self.top = top
    self.leading = leading
    self.bottom = bottom
    self.trailing = trailing
  }

  // MARK: Public

  // MARK: AdaptiveFloat

  // This type is nested to avoid conflicts with types like this that are common
  // in other codebases
  public enum AdaptiveFloat: Equatable, Hashable {
    /// Holds a single style for both size classes
    case fixed(CGFloat)
    /// Holds a compact and a regular style
    case adaptive(compact: CGFloat, regular: CGFloat)
    /// Holds sizes for compact and regular size classes, as well as
    /// compact and regular size classes when accessibility type sizes are enabled.
    /// This is checked using traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    case adaptiveAccessibility(
      compact: CGFloat,
      compactAccessibilitySizes: CGFloat,
      regular: CGFloat,
      regularAccessibilitySizes: CGFloat)
  }

  public let top: AdaptiveFloat
  public let leading: AdaptiveFloat
  public let bottom: AdaptiveFloat
  public let trailing: AdaptiveFloat

  public func edgeInsets(with traitCollection: UITraitCollection) -> UIEdgeInsets {
    .init(
      top: top.value(with: traitCollection),
      left: leading.value(with: traitCollection),
      bottom: bottom.value(with: traitCollection),
      right: trailing.value(with: traitCollection))
  }

  public func directionalEdgeInsets(with traitCollection: UITraitCollection) -> NSDirectionalEdgeInsets {
    .init(
      top: top.value(with: traitCollection),
      leading: leading.value(with: traitCollection),
      bottom: bottom.value(with: traitCollection),
      trailing: trailing.value(with: traitCollection))
  }
}

extension GroupEdgeInsets {
  public static var zero: GroupEdgeInsets {
    .init(top: 0, leading: 0, bottom: 0, trailing: 0)
  }
}

extension GroupEdgeInsets.AdaptiveFloat {
  /// Returns the appropriate CGFloat value for the provided traitCollection
  public func value(with traitCollection: UITraitCollection) -> CGFloat {
    switch self {
    case .fixed(let value):
      return value

    case .adaptive(compact: let compact, regular: let regular):
      switch traitCollection.horizontalSizeClass {
      case .compact, .unspecified:
        return compact
      case .regular:
        return regular
      @unknown default:
        return compact
      }

    case .adaptiveAccessibility(
      compact: let compact,
      compactAccessibilitySizes: let compactAccessibility,
      regular: let regular,
      regularAccessibilitySizes: let regularAccessibility):
      switch (traitCollection.horizontalSizeClass, traitCollection.preferredContentSizeCategory.isAccessibilityCategory) {
      case (.compact, false), (.unspecified, false):
        return compact
      case (.compact, true), (.unspecified, true):
        return compactAccessibility
      case (.regular, false):
        return regular
      case (.regular, true):
        return regularAccessibility
      @unknown default:
        return compact
      }
    }
  }
}
