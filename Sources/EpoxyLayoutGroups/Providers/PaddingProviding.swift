// Created by Tyler Hedrick on 3/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - PaddingProviding

/// Describes something that provides `padding`
public protocol PaddingProviding {
  /// The padding value
  var padding: NSDirectionalEdgeInsets { get }
}

// MARK: - CallbackContextEpoxyModeled

extension EpoxyModeled where Self: PaddingProviding {

  // MARK: Public

  /// The padding value represented by this model
  public var padding: NSDirectionalEdgeInsets {
    get { self[paddingProperty] }
    set { self[paddingProperty] = newValue }
  }

  /// Returns a copy of this model replacing the `padding` value
  /// with the one provided.
  public func padding(_ value: NSDirectionalEdgeInsets) -> Self {
    copy(updating: paddingProperty, to: value)
  }

  /// Returns a copy of this model replacing the `padding` value
  /// with one that has all edges set to the provided value.
  public func padding(_ value: CGFloat) -> Self {
    copy(updating: paddingProperty, to: .init(top: value, leading: value, bottom: value, trailing: value))
  }

  // MARK: Private

  private var paddingProperty: EpoxyModelProperty<NSDirectionalEdgeInsets> {
    .init(keyPath: \PaddingProviding.padding, defaultValue: .zero, updateStrategy: .replace)
  }
}
