// Created by eric_horacek on 10/24/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - NavigationController

/// A subclassable navigation controller that manages its visible view controllers declaratively via
/// an array of `NavigationModel`s that represent its navigation stack.
///
/// The `NavigationModel` representation of the entire navigation stack should be set at once via
/// `setStack(_:animated:)` whenever a change occurs, rather than being managed imperatively by
/// pushing and popping individual view controllers as is typical with `UINavigationController`.
open class NavigationController: UINavigationController {

  // MARK: Lifecycle

  /// - Parameter wrapNavigation: A closure that's called to wrap the given pushed navigation
  ///   controller into a wrapper container view controller to prevent the UIKit exception that's
  ///   thrown when a navigation controller is pushed within another navigation controller. Nesting
  ///   navigation controllers enables nesting sub-flows with an overarching flow.
  public init(wrapNavigation: ((_ nested: UINavigationController) -> UIViewController)? = nil) {
    self.wrapNavigation = wrapNavigation
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  @discardableResult
  open override func popViewController(animated: Bool) -> UIViewController? {
    guard let popped = super.popViewController(animated: animated) else {
      return nil
    }
    queue.didPop([popped], animated: animated, from: self)
    return popped
  }

  @discardableResult
  open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    guard let popped = super.popToRootViewController(animated: animated) else {
      return nil
    }
    queue.didPop(popped, animated: animated, from: self)
    return popped
  }

  @discardableResult
  open override func popToViewController(
    _ viewController: UIViewController,
    animated: Bool)
    -> [UIViewController]?
  {
    guard let popped = super.popToViewController(viewController, animated: animated) else {
      return nil
    }
    queue.didPop(popped, animated: animated, from: self)
    return popped
  }

  /// A method that can be overridden by subclasses to react to the navigation stack being updated.
  open func didSetViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    // Available to be overridden by subclasses.
  }

  // MARK: Public

  // MARK: UINavigationController

  @available (*, unavailable, message: "Manual management is not allowed, use `setStack(...)`")
  public final override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    EpoxyLogger.shared.assertionFailure(
      "Manual management of view controllers is not allowed, use `setStack(...)`")
  }

  @available (*, unavailable, message: "Manual management is not allowed, use `setStack(...)`")
  public final override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    EpoxyLogger.shared.assertionFailure(
      "Manual management of view controllers is not allowed, use `setStack(...)`")
  }

  /// Updates the navigation stack to the provided array of navigation models, optionally animating
  /// the transition.
  ///
  /// Only the differences between the previous stack and the provided stack are applied as changes
  /// to the view controller hierarchy.
  ///
  /// If a transition is in progress when this method is called, the provided stack is queued for
  /// subsequent presentation following the completion of the transition.
  ///
  /// Conceptually similar to `setSections(_:animated:)` for Epoxy models.
  public func setStack(_ stack: [NavigationModel?], animated: Bool) {
    queue.enqueue(stack.compactMap { $0 }, animated: animated, from: self)
  }

  /// Updates the navigation stack to the provided array of navigation models, optionally animating
  /// the transition.
  ///
  /// Only the differences between the previous stack and the provided stack are applied as changes
  /// to the view controller hierarchy.
  ///
  /// If a transition is in progress when this method is called, the provided stack is queued for
  /// subsequent presentation following the completion of the transition.
  ///
  /// Conceptually similar to `setSections(_:animated:)` for Epoxy models.
  public func setStack(_ stack: [NavigationModel], animated: Bool) {
    queue.enqueue(stack, animated: animated, from: self)
  }

  // MARK: Private

  private let queue = NavigationQueue()
  private let wrapNavigation: ((UINavigationController) -> UIViewController)?

}

// MARK: NavigationInterface

extension NavigationController: NavigationInterface {
  func setStack(_ stack: [UIViewController], animated: Bool) {
    // We don't call `self` since we've made it unavailable to consumers.
    super.setViewControllers(stack, animated: animated)

    didSetViewControllers(stack, animated: animated)
  }

  func wrapNavigation(_ navigationController: UINavigationController) -> UIViewController {
    wrapNavigation?(navigationController) ?? navigationController
  }
}
