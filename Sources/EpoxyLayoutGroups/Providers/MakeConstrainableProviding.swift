// Created by Tyler Hedrick on 3/25/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - MakeConstrainableProviding

/// The capability of constructing a `Constrainable`.
public protocol MakeConstrainableProviding {

  /// A closure that's called to construct a `Constrainable`.
  typealias MakeConstrainable = () -> Constrainable

  /// A closure that's called to construct a `Constrainable`.
  var makeConstrainable: MakeConstrainable { get }
}

// MARK: - ViewEpoxyModeled

extension EpoxyModeled where Self: MakeConstrainableProviding {

  // MARK: Public

  /// A closure that's called to construct a `Constrainable` represented by this model.
  public var makeConstrainable: MakeConstrainable {
    get { self[makeConstrainableProperty] }
    set { self[makeConstrainableProperty] = newValue }
  }

  /// Replaces the default closure to construct the constrainable with the given closure.
  public func makeConstrainable(_ value: @escaping MakeConstrainable) -> Self {
    copy(updating: makeConstrainableProperty, to: value)
  }

  // MARK: Private

  private var makeConstrainableProperty: EpoxyModelProperty<MakeConstrainable> {
    .init(
      keyPath: \MakeConstrainableProviding.makeConstrainable,
      defaultValue: UIView.init,
      updateStrategy: .replace)
  }
}
