// Created by eric_horacek on 10/23/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

/// A model of an element within a navigation stack that provides source of truth for whether its
/// `UIViewController` should be added to a corresponding `DeclarativeNavigationController`
///
/// Should be recreated and set on a `DeclarativeNavigationController` on every state change.
///
/// Conceptually similar to Epoxy models.
public struct NavigationModel {

  // MARK: Lifecycle

  /// Constructs a navigation stack element identified by its `dataID`, able to create a
  /// `UIViewController` from `Params` to be added to a navigation stack.
  ///
  /// Its `UIViewController` is constructed from `Params` and added to the navigation stack when
  /// this `NavigationModel` is set on a `DeclarativeNavigationController` via
  /// `setStack(_:animated:)` if:
  /// - A previous `NavigationModel` with the same `dataID` is not already added, or
  /// - A `NavigationModel` that has previously been added to the navigation stack with the same
  ///   `dataID` had `Params` that are not equal to this model's `Params`.
  ///
  /// - Parameters:
  ///   - params: The parameters this are used to construct the view controller to add to the stack.
  ///   - dataID: The identifier that distinguishes this element from others in the stack.
  ///   - makeViewController: A closure that's called with `Params` to construct the
  ///   `UIViewController` to be added to the navigation stack.
  ///   - remove: A closure that is called to update the state backing this navigation stack element
  ///     when its view controller is removed from the navigation stack. Not called if this
  ///     view controller is replaced by a new view controller with different `Params` and the same
  ///     data ID.
  public init<Params: Equatable>(
    params: Params,
    dataID: String,
    makeViewController: @escaping (Params) -> UIViewController?,
    remove: @escaping () -> Void)
  {
    self.dataID = dataID
    value = params as Any
    _makeViewController = { makeViewController(params) }
    _remove = remove
    _isValueEqual = { otherModel in
      guard let otherValue = otherModel.value as? Params else { return false }
      return otherValue == params
    }
  }

  /// Constructs a navigation stack element identified by its `dataID`, able to create a
  /// `UIViewController` to be added to a navigation stack.
  ///
  /// Its `UIViewController` is constructed added to the navigation stack when this
  /// `NavigationModel` is set on a `DeclarativeNavigationController` via `setStack(_:animated:)`
  /// if a previous `NavigationModel` with the same `dataID` is not already added to the navigation
  /// stack.
  ///
  /// - Parameters:
  ///   - dataID: The identifier that distinguishes this element from others in the stack.
  ///   - makeViewController: A closure that's called with to construct the `UIViewController` to be
  ///     added to the navigation stack.
  ///   - remove: A closure that is called to update the state backing this navigation stack element
  ///     when its view controller is removed from the navigation stack.
  public init(
    dataID: String,
    makeViewController: @escaping () -> UIViewController?,
    remove: @escaping () -> Void)
  {
    self.dataID = dataID
    value = ()
    _makeViewController = makeViewController
    _remove = remove
    _isValueEqual = { $0.value is Void }
  }

  /// Constructs a root navigation stack element identified by its `dataID`, able to create a
  /// `UIViewController` to be added to a navigation stack.
  ///
  /// Its `UIViewController` is constructed added to the navigation stack when this
  /// `NavigationModel` is set on a `DeclarativeNavigationController` via `setStack(_:animated:)`
  /// if a previous `NavigationModel` with the same `dataID` is not already added to the navigation
  /// stack.
  ///
  /// - Note: Unlike `init(dataID:makeViewController:remove:)`, there is no `remove` closure for a
  ///   `NavigationModel` constructed with this method. It's invalid to remove a root view
  ///   controller from a navigation stack; it can only be replaced. As such, this method should
  ///   only be used when modeling a navigation model that's the first element of a stack.
  ///
  /// - Parameters:
  ///   - dataID: The identifier that distinguishes this element from others in the stack.
  ///   - makeViewController: A closure that's called with to construct the `UIViewController` to be
  ///     added to the navigation stack.
  public static func root(
    dataID: String,
    makeViewController: @escaping () -> UIViewController?)
    -> NavigationModel
  {
    .init(dataID: dataID, makeViewController: makeViewController, remove: {})
  }

  // MARK: Public

  /// Calls the given closure when this model's view controller becomes visible at the top of a
  /// navigation stack that it has been added to.
  ///
  /// Any previously added `didShow` closures are called prior to the given closure.
  public func didShow(_ didShow: @escaping ((UIViewController) -> Void)) -> NavigationModel {
    var copy = self
    copy._didShow = { [oldDidShow = self._didShow] viewController in
      oldDidShow?(viewController)
      didShow(viewController)
    }
    return copy
  }

  /// Calls the given closure when this model's view controller is no longer visible at the top of
  /// a navigation stack that it has been added to.
  ///
  /// Any previously added `didHide` closures are called prior to the given closure.
  public func didHide(_ didHide: @escaping (() -> Void)) -> NavigationModel {
    var copy = self
    copy._didHide = { [oldDidHide = self._didHide] in
      oldDidHide?()
      didHide()
    }
    return copy
  }

  /// Calls the given closure when this model's view controller is added to a navigation stack.
  ///
  /// Any previously added `didAdd` closures are called prior to the given closure.
  public func didAdd(_ didAdd: @escaping ((UIViewController) -> Void)) -> NavigationModel {
    var copy = self
    copy._didAdd = { [oldDidAdd = self._didAdd] viewController in
      oldDidAdd?(viewController)
      didAdd(viewController)
    }
    return copy
  }

  /// Calls the given closure when this model's view controller is removed from a navigation stack.
  ///
  /// Any previously added `didRemove` closures are called prior to the given closure.
  public func didRemove(_ didRemove: @escaping (() -> Void)) -> NavigationModel {
    var copy = self
    copy._didRemove = { [oldDidRemove = self._didRemove] in
      oldDidRemove?()
      didRemove()
    }
    return copy
  }

  // MARK: Internal

  /// The identifier of this stack element that distinguishes it from other stack elements.
  let dataID: String

  /// Vends a closure that can be invoked to construct the view controller for this model if the
  /// `shown` value indicates shown, else `nil` if the `shown` value is dismissed.
  func makeViewController() -> UIViewController? {
    return _makeViewController()
  }

  /// Informs consumers of this model that its view controller has become visible at the top of a
  /// navigation stack that it has been added to.
  func handleDidShow(_ viewController: UIViewController) {
    _didShow?(viewController)
  }

  /// Informs consumers of this model that its view controller is no longer visible at the top of
  /// a navigation stack that it has been added to.
  func handleDidHide() {
    _didHide?()
  }

  /// Informs consumers of this model that its view controller has been added to the navigation
  /// stack.
  func handleDidAdd(_ viewController: UIViewController) {
    _didAdd?(viewController)
  }

  /// Informs consumers of this model that its view controller has been removed from the navigation
  /// stack.
  func handleDidRemove() {
    _didRemove?()
  }

  /// Updates the underlying state backing this model to remove it.
  func remove() {
    _remove()
  }

  // MARK: Private

  private let _makeViewController: () -> UIViewController?
  private let _remove: () -> Void
  private var _didShow: ((UIViewController) -> Void)?
  private var _didHide: (() -> Void)?
  private var _didAdd: ((UIViewController) -> Void)?
  private var _didRemove: (() -> Void)?

  /// Whether the given model's value is equal to this model's value.
  private var _isValueEqual: (NavigationModel) -> Bool

  /// The value of this model at the time of its creation.
  private var value: Any

}

// MARK: Diffable

extension NavigationModel: Diffable {
  public var diffIdentifier: String? { dataID }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableItem = otherDiffableItem as? NavigationModel else { return false }
    return _isValueEqual(otherDiffableItem)
  }
}
