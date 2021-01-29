// Created by eric_horacek on 10/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import FlowCoreUI
import UIKit

// MARK: - PresentationModel

/// A model that provides the means to construct a `UIViewController` for a modal presentation.
///
/// Should be recreated and set on a `UIViewController` on every state change.
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
      style: style,
      makePresentable: { params in
        makeViewController(params).map { .display($0) }
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
    self.dataID = dataID
    self.style = style
    value = ()
    _makePresentable = { makeViewController().map { .display($0) } }
    _dismiss = dismiss
    _isValueEqual = { $0.value is Void }
  }

  // MARK: Public

  /// Calls the given closure when the presentation completes successfully.
  ///
  /// Any previously added `didPresent` closures are called prior to the given closure.
  public func didPresent(_ didPresent: @escaping ((UIViewController) -> Void)) -> PresentationModel {
    var copy = self
    copy._didPresent = { [oldDidPresent = self._didPresent] viewController in
      oldDidPresent?(viewController)
      didPresent(viewController)
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

  /// Updates the presentation style to the given value.
  public func style(_ style: ModalTransitions.Style) -> PresentationModel {
    var copy = self
    copy.style = style
    return copy
  }

  // MARK: Internal

  /// The identifier of this presentation that distinguishes it from other presentations.
  let dataID: AnyHashable

  /// The style of the presentation.
  private(set) var style: ModalTransitions.Style

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

  func handleDidPresent(_ viewController: UIViewController) {
    _didPresent?(viewController)
  }

  func isValueEqual(to model: PresentationModel) -> Bool {
    _isValueEqual(model)
  }

  // MARK: Private

  private var _dismiss: () -> Void
  private var _didPresent: ((UIViewController) -> Void)?
  private var _didDismiss: (() -> Void)?
  private var _makePresentable: () -> Presentable?

  /// Whether the given model's value is equal to this model's value.
  private var _isValueEqual: (PresentationModel) -> Bool

  /// The value of this model at the time of its creation.
  private var value: Any

}

// MARK: Internal Lifecycle

extension PresentationModel {

  // MARK: Internal

  init<Params: Equatable>(
    params: Params,
    dataID: AnyHashable,
    style: ModalTransitions.Style,
    makePresentable: @escaping (Params) -> PresentationModel.Presentable?,
    dismiss: @escaping () -> Void)
  {
    self.dataID = dataID
    self.style = style
    _makePresentable = { makePresentable(params) }
    _dismiss = dismiss
    value = params
    _isValueEqual = { otherModel in
      guard let otherValue = otherModel.value as? Params else { return false }
      return otherValue == params
    }
  }

}

// MARK: - PresentationModel.Presentable

extension PresentationModel {
  /// A means to perform a presentation.
  ///
  /// Exists to allow different forms of presentation to coexist in this system (e.g. flow &
  /// display).
  struct Presentable {
    var presented: UIViewController
    var present: (Context) -> Dismissible

    /// The context that's provided to perform a presentation.
    struct Context {
      var presenting: UIViewController
      var animated: Bool
      var style: ModalTransitions.Style
      var hooks: ModalTransitions.Hooks
    }
  }
}

extension PresentationModel.Presentable {
  static func display(_ presented: UIViewController) -> PresentationModel.Presentable {
    PresentationModel.Presentable(presented: presented) { context in
      context.presenting.display(
        presented,
        style: context.style,
        animated: context.animated,
        hooks: context.hooks)
    }
  }
}
