// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - SetBehaviorsProviding

/// A sentinel protocol for enabling an `EpoxyModeled` to provide a `setBehaviors` closure property.
public protocol SetBehaviorsProviding {}

// MARK: - ContentViewEpoxyModeled

extension ContentViewEpoxyModeled where Self: SetBehaviorsProviding {

  // MARK: Public

  /// A closure that's called to configure this model's view with behaviors (e.g. tap handler
  /// closures) whenever this model is updated.
  public typealias SetBehaviors = ((ItemContext<View, Content>) -> Void)

  /// A closure that's called to configure this model's view with behaviors (e.g. tap handler
  /// closures) whenever this model is updated.
  public var setBehaviors: SetBehaviors? {
    get { self[setBehaviorsProperty] }
    set { self[setBehaviorsProperty] = newValue }
  }

  /// Returns a copy of this model with the set behaviors closure called after the current set
  /// behaviors closure of this model, if is one.
  public func setBehaviors(_ value: SetBehaviors?) -> Self {
    copy(updating: setBehaviorsProperty, to: value)
  }

  // MARK: Private

  private var setBehaviorsProperty: EpoxyModelProperty<SetBehaviors?> {
    .init(keyPath: \Self.setBehaviors, defaultValue: nil, updateStrategy: .chain())
  }
}
