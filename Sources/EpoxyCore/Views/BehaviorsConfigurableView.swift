// Created by Tyler Hedrick on 5/26/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - ViewBehaviors

/// Behaviors must be "resettable" - you should have a default initializer that sets all of your
/// behavior closures or delegates to `nil` in order for Epoxy to reset the behaviors on your view
/// when no behaviors are provided.
public protocol ViewBehaviors {
  /// Constructs an instance with no behaviors.
  init()
}

// MARK: - BehaviorsConfigurableView

/// A view that can be configured with a `Behaviors` instance that contains the view's non-
/// `Equatable` properties that can be updated on view instances after initialization, e.g. callback
/// closures or delegates.
///
/// Since it is not possible to establish the equality of two `Behaviors` instances, `Behaviors`
/// will be set more often than `ContentConfigurableView.Content`, needing to be updated every time
/// the view's corresponding `EpoxyModeled` instance is updated. As such, setting behaviors should
/// be as lightweight as possible.
///
/// Properties of `Behaviors` should mutually exclusive with the properties in the
/// `StyledView.Style` and `ContentConfigurableView.Content`.
///
/// - SeeAlso: `ContentConfigurableView`
/// - SeeAlso: `StyledView`
/// - SeeAlso: `EpoxyableView`
public protocol BehaviorsConfigurableView: UIView {
  /// The non-`Equatable` properties that can be changed over of the lifecycle this View's
  /// instances, e.g. callback closures or delegates.
  associatedtype Behaviors: ViewBehaviors = EmptyBehaviors

  /// Updates the behaviors of this view to those in the given `behaviors`.
  func setBehaviors(_ behaviors: Self.Behaviors)
}

// MARK: Defaults

extension BehaviorsConfigurableView where Behaviors == EmptyBehaviors {
  public func setBehaviors(_ behaviors: EmptyBehaviors) {
    // No-op
  }
}

// MARK: - EmptyBehaviors

public struct EmptyBehaviors: ViewBehaviors {
  public init() {}
}
