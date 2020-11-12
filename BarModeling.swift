// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCoreUI

// MARK: - BarModeling

/// A model that can provide an bar view to an `BarStackView`.
public protocol BarModeling {
  /// The wrapped internal bar model.
  var barModel: AnyBarModel { get }
}

// MARK: Defaults

extension BarModeling {
  /// The internal wrapped bar model.
  var internalBarModel: InternalBarCoordinating {
    barModel.model
  }
}

// MARK: - AnyBarModel

/// A wrapper type that allows the `InternalBarModeling` and `InternalBarCoordinating` protocols to
/// be internal.
public struct AnyBarModel {

  // MARK: Lifecycle

  init(_ model: InternalBarCoordinating) {
    self.model = model
  }

  // MARK: Internal

  /// Intentionally not public.
  var model: InternalBarCoordinating
}

// MARK: BarModeling

extension AnyBarModel: BarModeling {
  public var barModel: AnyBarModel { self }
}

// MARK: Diffable

extension AnyBarModel: Diffable {
  public var diffIdentifier: AnyHashable? {
    model.diffIdentifier
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    // If comparing to another `AnyBarModel`, compare the underlying models to one another since
    // concrete models attempt to cast the `Diffable` to their type.
    if let otherDiffableItem = otherDiffableItem as? AnyBarModel {
      return model.isDiffableItemEqual(to: otherDiffableItem.model)
    }

    return model.isDiffableItemEqual(to: otherDiffableItem)
  }

}
