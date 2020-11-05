// Created by eric_horacek on 11/4/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import ConstellationCoreUI

// MARK: - ConstellationBarModel

/// A `BarModel` with a `ConstellationView` as its view.
public typealias ConstellationBarModel<View: ConstellationView> = BarModel<View, View.Content>
  where
  View.Content: Equatable

// MARK: - StyledView

extension StyledView where Self: ContentConfigurableView, Self.Content: Equatable {
  /// Constructs a `BarModel` with an instance of this view as its bar.
  ///
  /// - Parameters:
  ///   - dataID: An optional ID that uniquely identifies this bar relative to other bars in the
  ///     same bar group. Defaults to a representation of this view's type under the assumption that
  ///     it is unlikely to have the same bar multiple times in a single bar stack.
  ///   - content: The content of the bar view that will be applied to the view via the
  ///     `setContent(_:animated:)` method whenver it has changed.
  ///   - style: The style of the bar view.
  /// - Returns: A `BarModel` with an instance of this view as its bar.
  public static func barModel(
    dataID: AnyHashable? = nil,
    content: Content,
    style: Style)
    -> ConstellationBarModel<Self>
  {
    ConstellationBarModel<Self>(
      dataID: dataID,
      content: content,
      makeView: { .make(style: style) },
      configureContent: { view, content, animated in
        view.setContent(content, animated: animated)
      })
      .configureBehaviors { view in
        // Reset any existing behaviors before calling additional behavior setters to ensure that
        // behaviors do not persist across view reuse.
        (view as? AnyBehaviorsConfigurableView)?.resetBehaviors()
      }
  }
}

// MARK: - BarModel + BehaviorsConfigurableView

extension BarModel where View: BehaviorsConfigurableView {
  /// Replaces the behaviors for the view with the given behaviors.
  public func behaviors(_ behaviors: View.Behaviors) -> Self {
    configureBehaviors { view in
      view.setBehaviors(behaviors)
    }
  }
}
