// Created by eric_horacek on 12/2/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore

// MARK: - WillDisplayProviding

public protocol WillDisplayProviding {
  /// A closure that's called when a view is about to be displayed.
  typealias WillDisplay = (() -> Void)

  /// A closure that's called when a view is about to be displayed
  var willDisplay: WillDisplay? {  get }
}

// MARK: - ContentViewEpoxyModeled

extension EpoxyModeled where Self: WillDisplayProviding {

  // MARK: Public

  /// A closure that's called when the view is about to be displayed.
  public var willDisplay: WillDisplay? {
    get { self[willDisplayProperty] }
    set { self[willDisplayProperty] = newValue }
  }

  /// Returns a copy of this model with the given will display closure called after the current will
  /// display closure of this model, if is one.
  public func willDisplay(_ value: WillDisplay?) -> Self {
    copy(updating: willDisplayProperty, to: value)
  }

  // MARK: Private

  private var willDisplayProperty: EpoxyModelProperty<WillDisplay?> {
    .init(keyPath: \WillDisplayProviding.willDisplay, defaultValue: nil, updateStrategy: .chain())
  }
}
