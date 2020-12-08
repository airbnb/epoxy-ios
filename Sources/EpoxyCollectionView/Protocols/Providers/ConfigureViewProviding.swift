// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - ConfigureViewProviding

/// A sentinel protocol for enabling an `EpoxyModeled` to provide a `configureView` closure
/// property.
public protocol ConfigureViewProviding {}

// MARK: - ContentViewEpoxyModeled

extension ContentViewEpoxyModeled where Self: ConfigureViewProviding {

  // MARK: Public

  /// A closure that's called to configure this model's view when it is first created and
  /// subsequently when the content changes.
  public typealias ConfigureView = (ItemContext<View, Content>) -> Void

  /// A closure that's called to configure this model's view when it is first created and
  /// subsequently when the content changes.
  public var configureView: ConfigureView? {
    get { self[configureViewProperty] }
    set { self[configureViewProperty] = newValue }
  }

  /// Returns a copy of this model with the given configure view closure called after the current
  /// configure view closure of this model, if is one.
  public func configureView(_ value: ConfigureView?) -> Self {
    copy(updating: configureViewProperty, to: value)
  }

  // MARK: Private

  private var configureViewProperty: EpoxyModelProperty<ConfigureView?> {
    .init(keyPath: \Self.configureView, defaultValue: nil, updateStrategy: .chain())
  }
}
