// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - InternalBarModeling

/// A model that can provide a bar view to a `BarStackView`.
///
/// Used to reference a `BarModel` without a generic type.
protocol InternalBarModeling: Diffable, EpoxyModeled {
  /// Constructs a configured bar view.
  func makeConfiguredView(traitCollection: UITraitCollection) -> UIView

  /// Configures the content of an existing bar view
  func configureContent(_ view: UIView, traitCollection: UITraitCollection, animated: Bool)

  /// Configures the behavior of an existing bar view.
  func configureBehavior(_ view: UIView, traitCollection: UITraitCollection)

  /// Should inform consumers that this bar model will be displayed.
  func willDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool)

  /// Should inform consumers that this bar model has been displayed.
  func didDisplay(_ view: UIView, traitCollection: UITraitCollection, animated: Bool)
}

// MARK: - InternalBarCoordinating

/// A model that can provide a bar coordinator to a `BarStackView`.
public protocol InternalBarCoordinating: Diffable, EpoxyModeled {
  /// Constructs the coordinator responsible for additional configuration of this bar.
  ///
  /// - Parameters:
  ///   - update: A closure that can be invoked to trigger the `BarModel` to be re-queried,
  ///     resulting in the bar being updated.
  ///   - animated: Whether the bar update should be animated.
  func makeCoordinator(update: @escaping (_ animated: Bool) -> Void) -> AnyBarCoordinating

  /// Constructs a configured bar model using this bar's corresponding coordinator.
  func barModel(for coordinator: AnyBarCoordinating) -> BarModeling

  /// Whether the given previously constructed coordinator can be reused by this bar model.
  func canReuseCoordinator(_ coordinator: AnyBarCoordinating) -> Bool
}
