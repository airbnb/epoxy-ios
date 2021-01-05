// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - MakeViewProviding

/// The capability of constructing a `UIView`.
public protocol MakeViewProviding {
  /// The view constructed when the `MakeView` closure is called.
  associatedtype View: UIView

  /// A closure that's called to construct an instance of `View`.
  typealias MakeView = () -> View

  /// A closure that's called to construct an instance of `View`.
  var makeView: MakeView { get }
}

// MARK: - ViewEpoxyModeled

extension ViewEpoxyModeled where Self: MakeViewProviding {

  // MARK: Public

  /// A closure that's called to construct an instance of `View` represented by this model.
  public var makeView: MakeView {
    get { self[makeViewProperty] }
    set { self[makeViewProperty] = newValue }
  }

  /// Replaces the default closure to construct the view with the given closure.
  public func makeView(_ value: @escaping MakeView) -> Self {
    copy(updating: makeViewProperty, to: value)
  }

  // MARK: Private

  private var makeViewProperty: EpoxyModelProperty<MakeView> {
    .init(keyPath: \Self.makeView, defaultValue: View.init, updateStrategy: .replace)
  }
}
