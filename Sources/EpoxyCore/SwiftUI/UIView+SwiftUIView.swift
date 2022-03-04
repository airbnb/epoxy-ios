// Created by eric_horacek on 3/3/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - UIViewProtocol + swiftUIView

extension UIViewProtocol {
  /// Returns a SwiftUI `View` representing this `UIView`, constructed with the given `makeView`
  /// closure and sized with the given sizing configuration.
  ///
  /// To perform additional configuration of the `UIView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyUIView.swiftUIView(…)
  ///   .configure { (view: MyUIView) in
  ///     …
  ///   }
  /// ```
  public static func swiftUIView(
    sizing: SwiftUISizingContainerConfiguration = .init(),
    makeView: @escaping () -> Self)
    -> SwiftUISizingContainer<SwiftUIUIView<Self>>
  {
    SwiftUISizingContainer(configuration: sizing) { context in
      SwiftUIUIView(context: context, makeView: makeView)
    }
  }
}

// MARK: - SwiftUIUIView

/// A `UIViewRepresentable` SwiftUI `View` that wraps its `Content` `UIView` within a
/// `SwiftUIMeasurementContainer`, expected to be provided a `SwiftUISizingContext` by a parent
/// `SwiftUISizingContainer`, used to size a UIKit view correctly within a SwiftUI view hierarchy.
public struct SwiftUIUIView<View: UIView>: UIViewRepresentable, SwiftUISizingContainerContent {

  // MARK: Public

  /// An array of closures that are invoked to configure the represented view.
  public var configurations: [(View) -> Void] = []

  /// Returns a copy of this view updated to have the given closure applied to its represented view
  /// whenever it is updated via the `updateUIView` method.
  public func configure(_ configure: @escaping (View) -> Void) -> Self {
    var copy = self
    copy.configurations.append(configure)
    return copy
  }

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    SwiftUIMeasurementContainer(view: self, uiView: makeView(), context: context)
  }

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context _: Context) {
    wrapper.view = self

    for configuration in configurations {
      configuration(wrapper.uiView)
    }
  }

  // MARK: Internal

  /// The sizing context used to size the represented view.
  var context: SwiftUISizingContext

  /// A closure that's invoked to construct the represented view.
  var makeView: () -> View
}

// MARK: - UIViewProtocol

/// A protocol that all `UIView`s conform to, enabling extensions that have a `Self` reference.
public protocol UIViewProtocol: UIView {}

// MARK: - UIView + UIViewProtocol

extension UIView: UIViewProtocol {}
