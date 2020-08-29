// Created by eric_horacek on 10/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import FlowCoreUI
import UIKit

// MARK: - PresentationModel

/// A model that provides the means to declaratively drive the modal presentations of a presenting
/// `UIViewController`.
///
/// Should be recreated and set on a presenting `UIViewController` on every state change.
///
/// Conceptually similar to Epoxy models.
public struct PresentationModel {

  // MARK: Lifecycle

  /// Constructs a presentation model identified by its `dataID`, able to create a
  /// `UIViewController` from `Params` to be presented.
  ///
  /// Its `UIViewController` is constructed and presented from `Params` when this
  /// `PresentationModel` is set on a view controller via `setPresentation(_:animated:)` if:
  /// - A previous presentation with the same `dataID` is not already presented, or
  /// - A previously presented `PresentationModel` with the same `dataID` had `Params` that are
  ///   not equal to this model's `Params`.
  ///
  /// - Parameters:
  ///   - params: The parameters this are used to construct the view controller to present.
  ///   - dataID: The identifier that distinguishes this presentation from others.
  ///   - style: The style of this presentation.
  ///   - makeViewController: A closure that's called with `Params` to construct the
  ///     `UIViewController` to be presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     presented view controller is dismissed. Not called if this presentation is replaced by a
  ///     new presentation with different `Params` and the same data ID.
  public init<Params: Equatable>(
    params: Params,
    dataID: AnyHashable,
    style: ModalTransitions.Style,
    makeViewController: @escaping (Params) -> UIViewController?,
    dismiss: @escaping () -> Void)
  {
    self.init(
      params: params,
      dataID: dataID,
      makePresentable: { params in
        makeViewController(params).map { viewController in
          .display(viewController, style: style)
        }
      },
      dismiss: dismiss)
  }

  /// Constructs a presentation model identified by its `dataID`, able to create a
  /// `UIViewController` to be presented.
  ///
  /// Its `UIViewController` is constructed and presented when this `PresentationModel` is set on a
  /// view controller via `setPresentation(_:animated:)` if a previous presentation with the same
  /// `dataID` is not already presented.
  ///
  /// - Parameters:
  ///   - dataID: The identifier that distinguishes this presentation from others.
  ///   - style: The style of this presentation.
  ///   - makeViewController: A closure that's called to construct the `UIViewController` to be
  ///     presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     presented view controller is dismissed.
  public init(
    dataID: AnyHashable,
    style: ModalTransitions.Style,
    makeViewController: @escaping () -> UIViewController?,
    dismiss: @escaping () -> Void)
  {
    self.init(
      dataID: dataID,
      makePresentable: {
        makeViewController().map { viewController in
          .display(viewController, style: style)
        }
      },
      dismiss: dismiss)
  }

  // MARK: Public

  /// Calls the given closure when the presentation completes successfully.
  ///
  /// Any previously added `didPresent` closures are called prior to the given closure.
  public func didPresent(_ didPresent: @escaping (() -> Void)) -> PresentationModel {
    var copy = self
    copy._didPresent = { [oldDidPresent = self._didPresent] in
      oldDidPresent?()
      didPresent()
    }
    return copy
  }

  /// Calls the given closure when dismissal completes successfully.
  ///
  /// Any previously added `didDismiss` closures are called prior to the given closure.
  public func didDismiss(_ didDismiss: @escaping (() -> Void)) -> PresentationModel {
    var copy = self
    copy._didDismiss = { [oldDidDismiss = self._didDismiss] in
      oldDidDismiss?()
      didDismiss()
    }
    return copy
  }

  // MARK: Internal

  /// The identifier of this presentation that distinguishes it from other presentations.
  let dataID: AnyHashable

  /// Vends a closure that can be invoked to construct the `Presentable` for this presentation if
  /// the `presentation` value is presented, else `nil` if the `presentation` value is dismissed.
  func makePresentable() -> Presentable? {
    _makePresentable()
  }

  func dismiss() {
    _dismiss()
  }

  func handleDidDismiss() {
    _didDismiss?()
  }

  func handleDidPresent() {
    _didPresent?()
  }

  func isValueEqual(to model: PresentationModel) -> Bool {
    _isValueEqual(model)
  }

  // MARK: Private

  private var _dismiss: () -> Void
  private var _didPresent: (() -> Void)?
  private var _didDismiss: (() -> Void)?
  private var _makePresentable: () -> Presentable?

  /// Whether the given model's value is equal to this model's value.
  private var _isValueEqual: (PresentationModel) -> Bool

  /// The value of this model at the time of its creation.
  private var value: Any

}

// MARK: Advanced Lifecycle

extension PresentationModel {
  /// Constructs a presentation model identified by its `dataID`, able to create a
  /// `Presentable` from `Params` to be presented.
  ///
  /// This initializer is not meant to be called directly by `PresentationModel` consumers. It is
  /// rather the most generic method to construct a `PresentationModel` that more specific
  /// initializers should call through to from an initializer that is specific to a type of
  /// `Presentable`, e.g. a `UIViewController`.
  ///
  /// Its `Presentable` is constructed and presented from `Params` when this `PresentationModel` is
  /// set on a view controller via `setPresentation(_:animated:)` if:
  /// - A previous presentation with the same `dataID` is not already presented, or
  /// - A previously presented `PresentationModel` with the same `dataID` had `Params` that are
  ///   not equal to this model's `Params`.
  ///
  /// - Parameters:
  ///   - params: The parameters this are used to construct the presentable to present.
  ///   - dataID: The identifier that distinguishes this presentation from others.
  ///   - makePresentable: A closure that's called with `Params` to construct the `Presentable` to
  ///     be presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     presented presentable is dismissed. Not called if this presentation is replaced by a new
  ///     presentation with different `Params` and the same data ID.
  public init<Params: Equatable>(
    params: Params,
    dataID: AnyHashable,
    makePresentable: @escaping (Params) -> Presentable?,
    dismiss: @escaping () -> Void)
  {
    self.dataID = dataID
    _makePresentable = { makePresentable(params) }
    _dismiss = dismiss
    value = params
    _isValueEqual = { otherModel in
      guard let otherValue = otherModel.value as? Params else { return false }
      return otherValue == params
    }
  }

  /// Constructs a presentation model identified by its `dataID`, able to create a
  /// `Presentable` to be presented.
  ///
  /// This initializer is not meant to be called directly by `PresentationModel` consumers. It is
  /// rather the most generic method to construct a `PresentationModel` that more specific
  /// initializers should call through to from an initializer that is specific to a type of
  /// `Presentable`, e.g. a `UIViewController`.
  ///
  /// Its `Presentable` is constructed and presented when this `PresentationModel` is set on a view
  /// controller via `setPresentation(_:animated:)` if a previous presentation with the same
  /// `dataID` is not already presented.
  ///
  /// - Parameters:
  ///   - dataID: The identifier that distinguishes this presentation from others.
  ///   - style: The style of this presentation.
  ///   - makePresentable: A closure that's called to construct the `Presentable` to be presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     presentable is dismissed.
  public init(
    dataID: AnyHashable,
    makePresentable: @escaping () -> Presentable?,
    dismiss: @escaping () -> Void)
  {
    self.dataID = dataID
    value = ()
    _makePresentable = makePresentable
    _dismiss = dismiss
    _isValueEqual = { $0.value is Void }
  }
}

// MARK: - PresentationModel.Presentable

extension PresentationModel {
  /// A means to perform a presentation for a `PresentationModel`.
  ///
  /// Exists to allow different forms of presentation to coexist in this system (e.g. flow, display,
  /// routing).
  public struct Presentable {

    // MARK: Lifecycle

    public init(present: @escaping (Context) -> Dismissible) {
      self.present = present
    }

    // MARK: Public

    /// The context that's provided to perform a presentation.
    public struct Context {
      /// The view controller that the presentation is performed on.
      public var presenting: ModalTransitioning

      /// Whether the presentation should be animated.
      public var animated: Bool

      /// The hooks that should be called as the presentation progresses.
      public var hooks: ModalTransitions.Hooks
    }

    /// A closure that's invoked to perform the presentation from the provided context, returning a
    /// `Dismissible` that can be used to dismiss the presentation.
    public var present: (Context) -> Dismissible

  }
}

extension PresentationModel.Presentable {
  static func display(_ presented: UIViewController, style: ModalTransitions.Style) -> Self {
    .init { context in
      context.presenting.display(
        presented,
        style: style,
        animated: context.animated,
        hooks: context.hooks)
    }
  }
}
