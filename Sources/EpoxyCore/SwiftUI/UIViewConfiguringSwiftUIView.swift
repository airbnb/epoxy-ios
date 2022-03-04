// Created by eric_horacek on 3/4/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - UIViewConfiguringSwiftUIView

/// A protocol describing a SwiftUI `View` that can configure its `UIView` contents via an array of
/// `configuration` closures.
public protocol UIViewConfiguringSwiftUIView: View {
  /// The `UIView` represented by this view.
  associatedtype View: UIView

  /// A mutable array of configuration closures that should each be invoked with the represented
  /// `UIView` whenever `updateUIView` is called in a `UIViewRepresentable`.
  var configurations: [(View) -> Void] { get set }
}

// MARK: Extensions

extension UIViewConfiguringSwiftUIView {
  /// Returns a copy of this view updated to have the given closure applied to its represented view
  /// whenever it is updated via the `updateUIView` method.
  public func configure(_ configure: @escaping (View) -> Void) -> Self {
    var copy = self
    copy.configurations.append(configure)
    return copy
  }

  /// Returns a copy of this view updated to have the given closures applied to its represented view
  /// whenever it is updated via the `updateUIView` method.
  public func configurations(_ configurations: [(View) -> Void]) -> Self {
    var copy = self
    copy.configurations.append(contentsOf: configurations)
    return copy
  }
}
