// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - AnyBarCoordinating

/// The behavior of `BarCoordinating` without an associated type.
public protocol AnyBarCoordinating: AnyObject {

  // MARK: Optional

  /// `self` in the default case, else the backing instance if a `AnyBarCoordinator`.
  var backing: AnyBarCoordinating { get }

}

// MARK: Defaults

extension AnyBarCoordinating {
  public var backing: AnyBarCoordinating { self }
}

// MARK: - BarCoordinating

/// A class responsible for configuring a bar view with additional action, e.g. navigation button
/// actions, scroll view offsets, etc. Is not recreated on every bar model update, so it can
/// maintain local state and trigger bar updates to occur outside of the normal data flow.
public protocol BarCoordinating: AnyBarCoordinating {
  /// The `BarModeling` that this coordinator is coordinating.
  associatedtype Model: BarModeling

  /// Vends the `BarModeling` to display the bar, populated with the content from its model.
  ///
  /// Should perform any necessary configuration of the bars that the coordinator has knowledge of
  /// and the navigation model does not, e.g. scroll offsets, navigation behaviors, etc.
  func barModel(for model: Model) -> BarModeling
}

// MARK: - AnyBarCoordinator

/// A navigation bar coordinator with a generic `BarModel` that can be referenced (unlike
/// `BarCoordinating`, due to its associated type).
final class AnyBarCoordinator<BarModel: BarModeling>: BarCoordinating {

  // MARK: Lifecycle

  init<Coordinator: BarCoordinating>(_ coordinator: Coordinator) where
    Coordinator.Model == BarModel
  {
    type = Coordinator.self
    _barModel = coordinator.barModel(for:)
    backing = coordinator
  }

  // MARK: Internal

  /// The type of the wrapped coordinator.
  let type: AnyClass

  let backing: AnyBarCoordinating

  func barModel(for navigationModel: BarModel) -> BarModeling {
    _barModel(navigationModel)
  }

  // MARK: Private

  private let _barModel: (_ barModel: BarModel) -> BarModeling

}

// MARK: - DefaultBarCoordinator

/// A bar coordinator that just returns the bar model that it's passed.
///
/// Used as the default coordinator when a consumer doesn't provide one.
final class DefaultBarCoordinator<BarModel: BarModeling>: BarCoordinating {

  // MARK: Lifecycle

  init(update: @escaping (_ animated: Bool) -> Void) {}

  // MARK: Internal

  func barModel(for model: BarModel) -> BarModeling { model }

}
