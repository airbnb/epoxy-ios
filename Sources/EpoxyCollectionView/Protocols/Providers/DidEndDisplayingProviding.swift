// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - DidEndDisplayingProviding

public protocol DidEndDisplayingProviding {
  /// A closure that's called when a view is no longer displayed.
  typealias DidEndDisplaying = (() -> Void)

  /// A closure that's called when a view is no longer displayed.
  var didEndDisplaying: DidEndDisplaying? {  get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: DidEndDisplayingProviding {

  // MARK: Public

  /// A closure that's called when a view is no longer displayed.
  public var didEndDisplaying: DidEndDisplaying? {
    get { self[didEndDisplayingProperty] }
    set { self[didEndDisplayingProperty] = newValue }
  }

  public func didEndDisplaying(_ value: DidEndDisplaying?) -> Self {
    copy(updating: didEndDisplayingProperty, to: value)
  }

  // MARK: Private

  private var didEndDisplayingProperty: EpoxyModelProperty<DidEndDisplaying?> {
    .init(
      keyPath: \DidEndDisplayingProviding.didEndDisplaying,
      defaultValue: nil,
      updateStrategy: .chain())
  }
}
