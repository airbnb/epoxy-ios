// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - DidChangeStateProviding

/// A sentinel protocol for enabling a `EpoxyModeled` to provide a `didChangeState` closure
/// property.
public protocol DidChangeStateProviding {}

// MARK: - ContentViewEpoxyModeled

extension ContentViewEpoxyModeled where Self: DidChangeStateProviding {

  // MARK: Public

  /// A closure that's called to configure the state of this model's view when it changes.
  public typealias DidChangeState = (ItemContext<View, Content>) -> Void

  /// A closure that's called to configure the state of this model's view when it changes.
  public var didChangeState: DidChangeState? {
    get { self[didChangeStateProperty] }
    set { self[didChangeStateProperty] = newValue }
  }

  /// Returns a copy of this model with the given did change state closure called after the current
  /// did change state closure of this model, if is one.
  public func didChangeState(_ value: DidChangeState?) -> Self {
    copy(updating: didChangeStateProperty, to: value)
  }

  // MARK: Private

  private var didChangeStateProperty: EpoxyModelProperty<DidChangeState?> {
    .init(keyPath: \Self.didChangeState, defaultValue: nil, updateStrategy: .chain())
  }
}
