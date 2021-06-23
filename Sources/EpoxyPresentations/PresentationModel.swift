// Created by eric_horacek on 10/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - PresentationModel

/// A model that provides the means to declaratively drive the modal presentations of a presenting
/// `UIViewController`.
///
/// Should be recreated and set on a presenting `UIViewController` on every state change.
public struct PresentationModel {

  // MARK: Lifecycle

  /// Constructs a presentation model identified by its `dataID`, able to create a
  /// `UIViewController` to be presented.
  ///
  /// Its `UIViewController` is constructed and presented when this `PresentationModel` is set on a
  /// view controller via `setPresentation(_:animated:)` if a previous presentation with the same
  /// `dataID` is not already presented.
  ///
  /// - Parameters:
  ///   - dataID: The identifier that distinguishes this presentation from others.
  ///   - presentation: The means to perform this presentation, e.g. `.system` for the system style.
  ///   - makeViewController: A closure that's called to construct the `UIViewController` to be
  ///     presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     `UIViewController` is dismissed.
  public init(
    dataID: AnyHashable,
    presentation: Presentation,
    makeViewController: @escaping () -> UIViewController?,
    dismiss: @escaping () -> Void)
  {
    self.init(
      dataID: dataID,
      makePresentable: { makeViewController().map(presentation.present) },
      dismiss: dismiss)
  }

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
  ///   - presentation: The means to perform this presentation, e.g. `.system` for the system style.
  ///   - makeViewController: A closure that's called with `Params` to construct the
  ///     `UIViewController` to be presented.
  ///   - dismiss: A closure that is called to update the state backing this presentation when its
  ///     presented view controller is dismissed. Not called if this presentation is replaced by a
  ///     new presentation with different `Params` and the same data ID.
  public init<Params: Equatable>(
    params: Params,
    dataID: AnyHashable,
    presentation: Presentation,
    makeViewController: @escaping (Params) -> UIViewController?,
    dismiss: @escaping () -> Void)
  {
    self.init(
      params: params,
      dataID: dataID,
      makePresentable: { makeViewController($0).map(presentation.present) },
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

// MARK: Diffable

extension PresentationModel: Diffable {
  public var diffIdentifier: AnyHashable { dataID }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableItem = otherDiffableItem as? PresentationModel else { return false }
    return _isValueEqual(otherDiffableItem)
  }
}

// MARK: Advanced Lifecycle

extension PresentationModel {
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
}

// MARK: - PresentationModel.Presentation

extension PresentationModel {
  /// A means to perform a presentation for a `PresentationModel`.
  ///
  /// Exists to allow different forms of presentation to coexist in `PresentationModel`s.
  public struct Presentation {

    // MARK: Lifecycle

    /// Creates a `Presentation` with a closure that's invoked to perform the presentation from the
    /// provided context, returning a `Dismissible` that can be used to dismiss the presentation.
    public init(present: @escaping (_ presented: UIViewController) -> Presentable) {
      self.present = present
    }

    // MARK: Public

    /// The context that's provided to perform a presentation.
    public struct Context {
      /// The view controller that the presentation is performed on.
      public var presenting: UIViewController

      /// Whether the presentation should be animated.
      public var animated: Bool

      /// A closure that must be invoked when presentation completes.
      public var didPresent: () -> Void

      /// A closure that must be invoked when the dismissal completes.
      public var didDismiss: () -> Void
    }

    /// A closure that's invoked to perform the presentation from the provided context, returning a
    /// `Dismissible` that can be used to dismiss the presentation.
    public var present: (_ presented: UIViewController) -> Presentable
  }

  /// A closure to present the `presented` view controller passed to the `present` closure of a
  /// `Presentation` using the details from the given `context`, returning a `Dismissible` that can
  /// be called subsequently to dismiss the presentation.
  public typealias Presentable = (_ context: Presentation.Context) -> Dismissible

  /// The means to dismiss a `Presentation` of a view controller and optionally receive a callback
  /// upon the dismissal's completion.
  ///
  /// Matches the signature of `UIViewController.dismiss(animated:completion:)`
  public typealias Dismissible = (_ animated: Bool, _ completion: (() -> Void)?) -> Void
}

// MARK: System

extension PresentationModel.Presentation {
  /// The iOS system default presentation style.
  ///
  /// Performed by calling `UIViewController.present(_:animated:completion:)` with the view
  /// controller to present.
  public static var system: Self {
    .init { presented in
      { context in
        // This is the only way we've found to know when an arbitrary view controller is dismissed
        // when presented using `present(_:animated:completion:)` method.
        var token: NSObjectProtocol?
        token = NotificationCenter.default
          .addObserver(
            forName: .init("\(UIPresentationController.self)DismissalTransitionDidEndNotification"),
            object: presented,
            queue: .main,
            using: { [didDismiss = context.didDismiss] _ in
              guard token != nil else { return }
              token = nil
              didDismiss()
            })

        context.presenting.present(
          presented,
          animated: context.animated,
          completion: context.didPresent)

        return { [weak presented] animated, completion in
          // Dismiss using `presentingViewController` instead of `context.presenting` to handle the
          // presented view controller being "re-hosted" into a new presented view controller.
          guard let presented = presented, let presenting = presented.presentingViewController else {
            completion?()
            return
          }

          // Only dismiss if not transitioning, to prevent errantly double-dismissing in cases where
          // dismissal triggers overlap.
          if let transitionCoordinator = presenting.transitionCoordinator {
            if let completion = completion {
              transitionCoordinator.animate(alongsideTransition: nil, completion: { _ in
                completion()
              })
            }
            return
          }

          presenting.dismiss(animated: animated, completion: completion)
        }
      }
    }
  }
}
