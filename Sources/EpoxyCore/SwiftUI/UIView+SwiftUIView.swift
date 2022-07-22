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
  ///
  /// To configure the sizing behavior of the `UIView` instance, call `sizing` on the returned
  /// SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…).sizing(.intrinsicSize)
  /// ```
  /// The sizing defaults to `.intrinsicHeightProposedWidth`.
  public static func swiftUIView(makeView: @escaping () -> Self) -> SwiftUIUIView<Self> {
    SwiftUIUIView(makeView: makeView)
  }
}

// MARK: - SwiftUIUIView

/// A `UIViewRepresentable` SwiftUI `View` that wraps its `Content` `UIView` within a
/// `SwiftUIMeasurementContainer`, used to size a UIKit view correctly within a SwiftUI view
/// hierarchy.
public struct SwiftUIUIView<View: UIView>: MeasuringUIViewRepresentable, UIViewConfiguringSwiftUIView {

  // MARK: Public

  /// An array of closures that are invoked to configure the represented view.
  public var configurations: [(View) -> Void] = []

  /// The sizing context used to size the represented view.
  public var sizing = SwiftUIMeasurementContainerStrategy.intrinsicHeightProposedWidth

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Self, View> {
    SwiftUIMeasurementContainer(
      view: self,
      uiView: makeView(),
      strategy: sizing)
  }

  public func updateUIView(_ wrapper: SwiftUIMeasurementContainer<Self, View>, context _: Context) {
    wrapper.view = self

    for configuration in configurations {
      configuration(wrapper.uiView)
    }
  }

  // MARK: Internal

  /// A closure that's invoked to construct the represented view.
  var makeView: () -> View
}

// MARK: - UIViewProtocol

/// A protocol that all `UIView`s conform to, enabling extensions that have a `Self` reference.
public protocol UIViewProtocol: UIView { }

// MARK: - UIView + UIViewProtocol

extension UIView: UIViewProtocol { }
