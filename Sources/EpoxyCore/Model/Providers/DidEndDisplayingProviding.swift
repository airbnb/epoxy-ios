// Created by eric_horacek on 12/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - DidEndDisplayingProviding

/// A sentinel protocol for enabling an `CallbackContextEpoxyModeled` to provide a
/// `didEndDisplaying` closure property.
public protocol DidEndDisplayingProviding {}

// MARK: - CallbackContextEpoxyModeled

extension CallbackContextEpoxyModeled where Self: DidEndDisplayingProviding {

  // MARK: Public

  /// A closure that's called when a view is no longer displayed.
  public typealias DidEndDisplaying = ((_ context: CallbackContext) -> Void)

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
      keyPath: \Self.didEndDisplaying,
      defaultValue: nil,
      updateStrategy: .chain())
  }
}
