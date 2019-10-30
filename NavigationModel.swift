// Created by eric_horacek on 10/23/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import BondCoreUI
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

  /// Constructs a navigation stack element driven by a `Bond` to its `Params?`, with its
  /// `UIViewController` created and added to the navigation stack when the `added` `Bond` is non-
  /// `nil`, and removed when `nil`.
  ///
  /// Whenever `added.get` is non-`nil` following a previous `nil` value, or is initially non-`nil`,
  /// the `UIViewController` is created from the non-`nil` `Param` and added to the navigation
  /// stack.
  ///
  /// When this model's `UIViewController` is popped from the navigation stack (e.g. from a dismiss
  /// edge swipe), `added` is `set` to `nil`. If `added` was previously non-`nil` and becomes `nil`,
  /// this model's `UIViewController` is removed from the navigation stack.
  ///
  /// If the previous model's `Param` is non-`nil` and unequal to this model's non-`nil` `Params`,
  /// the previous `UIViewController` is replaced with a new `UIViewController` constructed from the
  /// current `added` `Param`.
  ///
  /// - Parameter added: Whether this element is added to the navigation stack.
  /// - Parameter dataID: The identifier that distinguishes this element from others in the stack.
  /// - Parameter makeViewController: A closure that's called with `Params` to construct the
  ///   `UIViewController` to be added to the navigation stack.
  public init<Params: Equatable>(
    added: Bond<Params?>,
    dataID: String,
    makeViewController: @escaping (Params) -> UIViewController)
  {
    self.init(added: added, dataID: dataID, isEqual: ==, makeViewController: makeViewController)
  }

  /// Constructs a navigation stack element driven by a `Bond` to its `Params?`, with its
  /// `UIViewController` created and added to the navigation stack when the `added` `Bond` is non-
  /// `nil`, and removed when `nil`.
  ///
  /// Whenever `added.get` is non-`nil` following a previous `nil` value, or is initially non-`nil`,
  /// the `UIViewController` is created from the non-`nil` `Param` and added to the navigation
  /// stack.
  ///
  /// When this model's `UIViewController` is popped from the navigation stack (e.g. from a dismiss
  /// edge swipe), `added` is `set` to `nil`. If `added` was previously non-`nil` and becomes `nil`,
  /// this model's `UIViewController` is removed from the navigation stack.
  ///
  /// If the previous model's `Params` is non-`nil` and _referentially_ unequal to this model's non-
  /// `nil` `added` `Params`, the previous `UIViewController` is replaced with a new
  /// `UIViewController` constructed from the current `added` `Param`.
  ///
  /// - Parameter added: Whether this element is added to the navigation stack.
  /// - Parameter dataID: The identifier that distinguishes this element from others in the stack.
  /// - Parameter makeViewController: A closure that's called with `Params` to construct the
  ///   `UIViewController` to be added to the navigation stack.
  public init<Params: AnyObject>(
    added: Bond<Params?>,
    dataID: String,
    makeViewController: @escaping (Params) -> UIViewController)
  {
    self.init(added: added, dataID: dataID, isEqual: ===, makeViewController: makeViewController)
  }

  /// Constructs a navigation stack element driven by a `Bond` to a `Bool`, with its view controller
  /// added to the navigation stack when the `Bond`'s value is `true`, and removed when `false`.
  ///
  /// Whenever `added.get` is `true` following a previous `false` value, or is initially `true`, the
  ///  `UIViewController` is created and added to the navigation stack.
  ///
  /// When this model's `UIViewController` is popped from the navigation stack (e.g. from a dismiss
  /// edge swipe), `added` is `set` to `false`. If `added` was previously `true` and becomes
  /// `false`, this model's `UIViewController` is removed from the navigation stack.
  ///
  /// - Parameter added: Whether this element is added to the navigation stack.
  /// - Parameter dataID: The identifier that distinguishes this element from others in the stack.
  /// - Parameter makeViewController: A closure that's called to construct the `UIViewController` to
  ///   be added to the navigation stack.
  public init(
    added: Bond<Bool>,
    dataID: String,
    makeViewController: @escaping () -> UIViewController)
  {
    self.dataID = dataID

    _makeViewController = { added.value ? makeViewController : nil }

    _didRemove = {
      // Only set if needed, since sets are typically more expensive than gets.
      guard added.value else { return }
      added.value = false
    }

    let value = added.value

    _isDiffableItemEqual = { otherModel in
      guard let otherModel = otherModel as? NavigationModel else { return false }
      guard let otherValue = otherModel._value as? Bool else { return false }
      return otherValue == value
    }

    _value = value
  }

  private init<Value>(
    added: Bond<Value?>,
    dataID: String,
    isEqual: @escaping (Value?, Value?) -> Bool,
    makeViewController: @escaping (Value) -> UIViewController)
  {
    self.dataID = dataID

    _makeViewController = {
      added.value.map { value in
        { makeViewController(value) }
      }
    }

    _didRemove = {
      // Only set if needed, since sets are typically more expensive than gets.
      guard added.value != nil else { return }
      added.value = nil
    }

    let value = added.value

    _isDiffableItemEqual = { otherModel in
      guard let otherModel = otherModel as? NavigationModel else { return false }
      guard let otherValue = dynamicCast(otherModel._value, to: Value?.self) else { return false }
      return isEqual(otherValue, value)
    }

    _value = value as Any
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
      oldDidRemove()
      didRemove()
    }
    return copy
  }

  // MARK: Internal

  /// The identifier of this stack element that distinguishes it from other stack elements.
  let dataID: String

  /// Vends a closure that can be invoked to construct the view controller for this model if the
  /// `shown` value indicates shown, else `nil` if the `shown` value is dismissed.
  var makeViewController: (() -> UIViewController)? {
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
    _didRemove()
  }

  // MARK: Private

  private let _makeViewController: () -> (() -> UIViewController)?
  private var _didShow: ((UIViewController) -> Void)?
  private var _didHide: (() -> Void)?
  private var _didAdd: ((UIViewController) -> Void)?
  private var _didRemove: () -> Void

  /// Whether the given model is equal to this model.
  private var _isDiffableItemEqual: (Diffable) -> Bool

  /// The value of this model's `Bond` at the time of its creation.
  private var _value: Any

}

// MARK: Diffable

extension NavigationModel: Diffable {
  public var diffIdentifier: String? {
    return dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    return _isDiffableItemEqual(otherDiffableItem)
  }
}

// MARK: - Helpers

/// A function that casts the provided value to the given type.
///
/// Solves [this](https://forums.swift.org/t/casting-from-any-to-optional/21883) issue.
private func dynamicCast<T>(_ value: Any, to _: T.Type) -> T? {
  return value as? T
}
