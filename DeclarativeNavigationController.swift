// Created by eric_horacek on 10/24/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// A navigation controller that manages its visible view controllers declaratively via an array of
/// `NavigationModel`s that models its navigation stack.
///
/// The representation of the entire the navigation stack should be set at once via `setStack(...)`
/// whenever a change occurrs, rather than managed imperatively by pushing and popping individual
/// view controllers.
///
/// Conceptually similar to `TableView` and `CollectionView` in Epoxy, with `NavigationModel`
/// equivalent to `EpoxyableModel`.
open class DeclarativeNavigationController: UINavigationController {

  // MARK: Lifecycle

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController overrides

  @available (*, unavailable, message: "Manual management is not allowed, use `setStack(...)`")
  public final override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    assertionFailure("Manual management of view controllers is not allowed, use `setStack(...)`")
  }

  @available (*, unavailable, message: "Manual management is not allowed, use `setStack(...)`")
  public final override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    assertionFailure("Manual management of view controllers is not allowed, use `setStack(...)`")
  }

  @discardableResult
  open override func popViewController(animated: Bool) -> UIViewController? {
    guard let popped = super.popViewController(animated: animated) else { return nil }
    queue.didPop([popped], animated: animated, from: self)
    return popped
  }

  @discardableResult
  open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    guard let popped = super.popToRootViewController(animated: animated) else { return nil }
    queue.didPop(popped, animated: animated, from: self)
    return popped
  }

  // MARK: Public

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

}

// MARK: NavigationInterface

extension DeclarativeNavigationController: NavigationInterface {
  func setStack(_ stack: [UIViewController], animated: Bool) {
    // We don't call `self` since we've made it unavailable to consumers.
    super.setViewControllers(stack, animated: animated)
  }
}
