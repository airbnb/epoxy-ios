// Created by eric_horacek on 4/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - InternalBarModeling

/// A model that can provide a bar view to a `BarStackView`.
///
/// Used to reference a `BarModel` without a generic type.
protocol InternalBarModeling: Diffable {
  /// Constructs a configured bar view.
  func makeConfiguredView() -> UIView

  /// Configures the content of an existing bar view
  func configureContent(_ view: UIView, animated: Bool)

  /// Configures the behavior of an existing bar view.
  func configureBehavior(_ view: UIView)

  /// Returns whether the given bar model has equal content to this bar model.
  func isContentEqual(to model: InternalBarModeling) -> Bool

  /// Returns whether the given bar model's view can be reused by this bar model.
  func canReuseView(from model: InternalBarModeling) -> Bool

  /// Should inform consumers that this bar model will be displayed.
  func willDisplay(_ view: UIView)

  /// Should inform consumers that this bar model has been displayed.
  func didDisplay(_ view: UIView)
}

// MARK: - InternalBarCoordinating

/// A model that can provide a bar coordinator to a `BarStackView`.
protocol InternalBarCoordinating: Diffable {
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
