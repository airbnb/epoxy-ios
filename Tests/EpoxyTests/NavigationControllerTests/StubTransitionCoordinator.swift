// Created by eric_horacek on 10/22/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - StubTransitionCoordinator

final class StubTransitionCoordinator: NSObject {

  // MARK: Lifecycle

  init(isAnimated: Bool = true) {
    self.isAnimated = isAnimated
  }

  // MARK: Internal

  var isAnimated: Bool
  var completeHandlers = [(UIViewControllerTransitionCoordinatorContext) -> Void]()
  var from: UIViewController?
  var to: UIViewController?
  var isCancelled = false

  func complete() {
    // Calling completion handlers in reverse order that they're added matches UIKit behavior.
    completeHandlers.reversed().forEach { $0(self) }
    completeHandlers = []
  }

}

// MARK: UIViewControllerTransitionCoordinator

extension StubTransitionCoordinator: UIViewControllerTransitionCoordinator {

  var initiallyInteractive: Bool { fatalError("Not implemented") }
  var isInterruptible: Bool { fatalError("Not implemented") }
  var isInteractive: Bool { fatalError("Not implemented") }
  var transitionDuration: TimeInterval { fatalError("Not implemented") }
  var percentComplete: CGFloat { fatalError("Not implemented") }
  var presentationStyle: UIModalPresentationStyle { fatalError("Not implemented") }
  var completionVelocity: CGFloat { fatalError("Not implemented") }
  var completionCurve: UIView.AnimationCurve { fatalError("Not implemented") }
  var containerView: UIView { fatalError("Not implemented") }
  var targetTransform: CGAffineTransform { fatalError("Not implemented") }

  func animate(
    alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
    completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil)
    -> Bool
  {
    animation?(self)
    completion.map { completeHandlers.append($0) }
    return true
  }

  // swiftlint:disable unavailable_function
  func animateAlongsideTransition(
    in view: UIView?,
    animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
    completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool
  {
    fatalError("Not implemented")
  }

  // swiftlint:disable unavailable_function
  func notifyWhenInteractionEnds(
    _ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void)
  {
    fatalError("Not implemented")
  }

  // swiftlint:disable unavailable_function
  func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
    fatalError("Not implmented")
  }

  func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
    switch key {
    case UITransitionContextViewControllerKey.to: return to
    case UITransitionContextViewControllerKey.from: return from
    default: return nil
    }
  }

  func view(forKey key: UITransitionContextViewKey) -> UIView? {
    fatalError("Not implemented")
  }

}
