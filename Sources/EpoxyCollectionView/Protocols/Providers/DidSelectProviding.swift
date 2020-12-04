// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - DidSelectProviding

/// A sentinel protocol for enabling an `EpoxyModeled` to provide a `didSelect` closure property.
public protocol DidSelectProviding {}

// MARK: - ContentViewEpoxyModeled

extension ContentViewEpoxyModeled where Self: DidSelectProviding {

  // MARK: Public

  /// A closure that's called to handle this model's view being selected.
  public typealias DidSelect = ((EpoxyContext<View, Content>) -> Void)

  /// A closure that's called to handle this model's view being selected.
  public var didSelect: DidSelect? {
    get { self[didSelectProperty] }
    set { self[didSelectProperty] = newValue }
  }

  /// Returns a copy of this model with the given did select closure called after the current did
  /// select closure of this model, if is one.
  public func didSelect(_ value: DidSelect?) -> Self {
    copy(updating: didSelectProperty, to: value)
  }

  // MARK: Private

  private var didSelectProperty: EpoxyModelProperty<DidSelect?> {
    .init(keyPath: \Self.didSelect, defaultValue: nil, updateStrategy: .chain())
  }
}
