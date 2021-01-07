// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - BarModeling

/// A model that can provide an bar view to an `BarStackView`.
public protocol BarModeling {
  /// Returns this bar model with its type erased to the `AnyItemModel` type.
  func eraseToAnyBarModel() -> AnyBarModel
}

// MARK: Defaults

extension BarModeling {
  /// The internal wrapped bar model.
  var internalBarModel: InternalBarCoordinating {
    eraseToAnyBarModel().model
  }
}
