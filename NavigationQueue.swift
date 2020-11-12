// Created by eric_horacek on 10/23/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCoreUI
import UIKit

// MARK: - NavigationInterface

/// The interface that's available to a `NavigationQueue` to manage the visible view controllers
/// within a navigation stack.
///
/// Rougly matches the API of `UINavigationController`.
protocol NavigationInterface: AnyObject {
  /// The active transition coordinator object.
  var transitionCoordinator: UIViewControllerTransitionCoordinator? { get }

  /// Sets the current stack of view controllers, optionally animated.
  func setStack(_ stack: [UIViewController], animated: Bool)

  /// Wraps a pushed `UINavigationController` within a container view controller so that it can be
  /// pushed without an exception being thrown by UIKit.
  func wrapNavigation(_ navigationController: UINavigationController) -> UIViewController
}

// MARK: - NavigationQueue

/// A data structure that maintains a FIFO 2-queue of navigation stacks.
///
/// Enables a declarative API for managing a navigation controller's stack.
final class NavigationQueue {

  // MARK: Internal

  /// Enqueues the given navigation model stack into this queue, updating the interface's view
  /// controller stack with the differences from the previous stack if a transition is not in
  /// progress, otherwise updating once the in-progress transition completes.
  func enqueue(_ models: [NavigationModel], animated: Bool, from interface: NavigationInterface) {
    guard !isTransitioning(animated: animated, from: interface) else {
      next = models
      return
    }

    let next = nextFrom(models, previous: current, interface: interface)
    applyNext(next, from: current, animated: animated, to: interface)
  }

  /// Handles the given portion of the view controller stack being popped.
  ///
  /// Expected to be called with the results of and immediately following:
  /// - `popViewController(animated:)`
  /// - `popToRootViewController(animated:)`
  func didPop(_ popped: [UIViewController], animated: Bool, from interface: NavigationInterface) {
    guard !popped.isEmpty else { return }

    guard let current = current else {
      assertionFailure("Popped \(popped) with no current, this is programmer error.")
      return
    }

    guard let coordinator = interface.transitionCoordinator else {
      isTransitioning = true
      (self.current, next) = applyPopped(popped, from: current, next: next)
      stopTransition(interface: interface, animated: animated)
      return
    }

    isTransitioning = true
    coordinator.animate(
      alongsideTransition: nil,
      completion: { [weak self, weak interface] context in
        guard let self = self, let interface = interface else { return }
        if !context.isCancelled {
          (self.current, self.next) = self.applyPopped(popped, from: current, next: self.next)
        }
        self.stopTransition(interface: interface, animated: animated)
      })
  }

  // MARK: Private

  /// The current navigation stack on this queue, else `nil` if there is no current.
  private var current: NavigationStack?

  /// The next stack of navigation models on this queue, else `nil` if there is no next.
  private var next: [NavigationModel]?

  /// Whether a push or pop transition is in progress.
  private var isTransitioning = false

  /// Returns the next navigation stack and changes that results from applying the given models to
  /// the provided previous stack.
  private func nextFrom(
    _ models: [NavigationModel],
    previous: NavigationStack?,
    interface: NavigationInterface)
    -> (stack: NavigationStack, changes: NavigationStack.AppliedChanges)
  {
    guard var next = previous else {
      let stack = NavigationStack(models: models, wrapNavigation: interface.wrapNavigation)
      return (stack: stack, changes: .init(removals: [], additions: stack.added))
    }
    let changes = next.applyModels(models, wrapNavigation: interface.wrapNavigation)
    return (stack: next, changes: changes)
  }

  /// Returns the next navigation stack after performing any necessary side-effects to apply it.
  private func applyNext(
    _ next: (stack: NavigationStack, changes: NavigationStack.AppliedChanges),
    from previous: NavigationStack?,
    animated: Bool,
    to interface: NavigationInterface)
  {
    interface.setStack(next.stack.viewControllerStack, animated: animated)

    // We want to make sure not to capture any removed view controllers.
    let notify = { [changes = next.changes, next = next.stack.addedTop, prev = previous?.addedTop?.model] in
      changes.removals.forEach { change in
        change.remove()
        change.handleDidRemove()
      }
      changes.additions.forEach { $0.model.handleDidAdd($0.viewController.made) }
      NavigationStack.Added.handleTopChange(from: prev, to: next)
    }

    if let coordinator = interface.transitionCoordinator {
      isTransitioning = true
      current = next.stack

      coordinator.animate(
        alongsideTransition: nil,
        completion: { [weak self, weak interface] context in
          guard let interface = interface else { return }
          if !context.isCancelled {
            notify()
          }
          self?.stopTransition(interface: interface, animated: animated)
        })
    } else {
      isTransitioning = true
      notify()
      current = next.stack
      stopTransition(interface: interface, animated: animated)
    }
  }

  /// Whether the given interface is actively transitioning.
  ///
  /// Has a side-effect of tracking the transition if `true` is returned, which will defer any
  /// submitted navigation stacks until after the transition.
  private func isTransitioning(animated: Bool, from interface: NavigationInterface) -> Bool {
    guard !isTransitioning else { return true }
    guard let coordinator = interface.transitionCoordinator else { return false }
    transitionAlongside(coordinator, animated: animated, from: interface)
    return true
  }

  /// Updates `isTransitioning` alongside the given transition coordinator.
  private func transitionAlongside(
    _ coordinator: UIViewControllerTransitionCoordinator,
    animated: Bool,
    from interface: NavigationInterface)
  {
    isTransitioning = true

    coordinator.animate(
      alongsideTransition: nil,
      completion: { [weak self, weak interface] _ in
        guard let interface = interface else { return }
        self?.stopTransition(interface: interface, animated: animated)
      })
  }

  /// Sets `isTransitioning` to `false` at the completion of a transition and enqueues the `next`
  /// navigation stack if there is one.
  private func stopTransition(interface: NavigationInterface, animated: Bool) {
    guard isTransitioning else { return }
    isTransitioning = false

    if let next = next {
      self.next = nil
      enqueue(next, animated: animated, from: interface)
    }
  }

  /// Returns the next navigation stack after performing any necessary side-effects resulting from
  /// the given view controllers being popped.
  private func applyPopped(
    _ popped: [UIViewController],
    from current: NavigationStack,
    next: [NavigationModel]?)
    -> (current: NavigationStack, next: [NavigationModel]?)
  {
    var updatedCurrent = current
    let removals = updatedCurrent.applyPopped(popped)

    removals.forEach { removed in
      removed.remove()
      removed.handleDidRemove()
    }

    NavigationStack.Added.handleTopChange(from: current.addedTop?.model, to: updatedCurrent.addedTop)

    // If there's a next model that's identical to the removed model, filter it out since it was just
    // removed and we don't want to add it back when we apply next.
    let updatedNext = next?.filter { model in
      !removals.contains { removal in
        removal.dataID == model.dataID && removal.isDiffableItemEqual(to: removal)
      }
    }

    return (current: updatedCurrent, next: updatedNext)
  }

}

// MARK: - NavigationStack

/// A navigation stack on the queue.
private struct NavigationStack {

  // MARK: Lifecycle

  init(models: [NavigationModel], wrapNavigation: (UINavigationController) -> UIViewController) {
    self.models = models
    viewControllers = models.map { ViewController(model: $0, wrapNavigation: wrapNavigation) }
  }

  // MARK: Internal

  /// The additions and removals resulting from applying a new set of models to this stack.
  struct AppliedChanges {
    var removals: [NavigationModel]
    var additions: [Added]
  }

  /// The models within this navigation stack.
  private(set) var models: [NavigationModel]

  /// The view controllers within this navigation stack, with indexes matching `models`.
  private(set) var viewControllers: [ViewController?]

  /// The view controllers that are pushed in the corresponding navigation controller. Indexes do
  /// not match `models`, as some models may not have been able to create a view controller.
  var viewControllerStack: [UIViewController] {
    viewControllers.compactMap { $0?.stackable }
  }

  /// Returns the added models and their corresponding view controllers in this stack.
  var added: [Added] {
    zip(models, viewControllers).compactMap { modelAndViewController in
      modelAndViewController.1.map { viewController in
        Added(model: modelAndViewController.0, viewController: viewController)
      }
    }
  }

  /// Returns the topmost added model and its corresponding view controller of this stack, else
  /// `nil` if there is none.
  var addedTop: Added? {
    added.last
  }

  /// Applies the given models to this navigation stack, returning the navigation models that were
  /// removed and added from the stack.
  mutating func applyModels(
    _ newModels: [NavigationModel],
    wrapNavigation: (UINavigationController) -> UIViewController)
    -> AppliedChanges
  {
    var newViewControllers = viewControllers
    let changeset = newModels.makeChangeset(from: models)
    var changes = AppliedChanges(removals: [], additions: [])
    var makeFailures = Set<Int>()

    for (from, to) in changeset.updates {
      let toModel = newModels[to]
      let toViewController = ViewController(model: toModel, wrapNavigation: wrapNavigation)
      newViewControllers[from] = toViewController

      switch (from: viewControllers[from], to: toViewController) {
      case (from: .some, to: nil):
        changes.removals.append(models[from])
        makeFailures.insert(to)
      case (from: nil, to: let toViewController?):
        changes.additions.append(.init(model: toModel, viewController: toViewController))
      case (from: nil, to: nil), (from: .some, to: .some):
        break
      }
    }

    for index in changeset.deletes.reversed() {
      newViewControllers.remove(at: index)
      changes.removals.append(models[index])
    }

    for index in changeset.inserts {
      let model = newModels[index]
      let viewController = ViewController(model: model, wrapNavigation: wrapNavigation)
      newViewControllers.insert(viewController, at: index)
      if let viewController = viewController {
        changes.additions.append(.init(model: model, viewController: viewController))
      } else {
        makeFailures.insert(index)
      }
    }

    for (from, to) in changeset.moves {
      newViewControllers[to] = viewControllers[from]
    }

    // If there's `nil` view controllers after reconciliation (where `makeViewController` previously
    // returned `nil`) that didn't show up as an update or insert, try to make them again, since
    // `makeViewController` could now be returning a non-`nil` value.
    for
      viewController in newViewControllers.enumerated() where
      viewController.element == nil && !makeFailures.contains(viewController.offset)
    {
      let index = viewController.offset
      let model = newModels[index]
      if let viewController = ViewController(model: model, wrapNavigation: wrapNavigation) {
        newViewControllers[index] = viewController
        changes.additions.append(.init(model: model, viewController: viewController))
      }
    }

    models = newModels
    viewControllers = newViewControllers
    return changes
  }

  /// Updates the internal state to handle the provided view controllers being popped from the
  /// stack, returning the models that were removed.
  mutating func applyPopped(_ popped: [UIViewController]) -> [NavigationModel] {
    var removals = [NavigationModel]()
    for element in popped {
      guard let index = viewControllers.firstIndex(where: { $0?.stackable === element }) else {
        assertionFailure("\(element) not in \(viewControllers), this is programmer error.")
        continue
      }
      viewControllers.remove(at: index)
      removals.append(models.remove(at: index))
    }
    return removals
  }

}

// MARK: - NavigationStack.Added

extension NavigationStack {
  /// A model that has been added to the navigation stack and its corresponding view controller.
  struct Added {
    var model: NavigationModel
    var viewController: ViewController

    static func handleTopChange(from previous: NavigationModel?, to next: Added?) {
      switch (previous: previous, next: next) {
      case (.some(let previous), .some(let next)):
        if previous.dataID != next.model.dataID {
          previous.handleDidHide()
          next.model.handleDidShow(next.viewController.made)
        }
      case (nil, .some(let next)):
        next.model.handleDidShow(next.viewController.made)
      case (.some(let previous), nil):
        previous.handleDidHide()
      case (nil, nil):
        break
      }
    }
  }
}

// MARK: - NavigationStack.ViewController

extension NavigationStack {
  /// A view controller that can be pushed within a `NavigationStack`.
  enum ViewController {

    /// A normal view controller that can be pushed within a navigation stack without issue.
    case normal(UIViewController)
    /// A nested navigation controller that must be wrapped within a container view controller to be
    /// pushed within a navigation stack to prevent UIKit from throwing an exception.
    case wrapped(UINavigationController, wrapper: UIViewController)

    // MARK: Lifecycle

    init?(model: NavigationModel, wrapNavigation: (UINavigationController) -> UIViewController) {
      guard let viewController = model.makeViewController() else { return nil }

      if let viewController = viewController as? UINavigationController {
        self = .wrapped(viewController, wrapper: wrapNavigation(viewController))
      } else {
        self = .normal(viewController)
      }
    }

    // MARK: Internal

    /// The view controller that was made by the navigation model
    var made: UIViewController {
      switch self {
      case .normal(let viewController): return viewController
      case .wrapped(let wrapped, wrapper: _): return wrapped
      }
    }

    /// The view controller that can be pushed into the nav stack.
    var stackable: UIViewController {
      switch self {
      case .normal(let viewController): return viewController
      case .wrapped(_, wrapper: let wrapper): return wrapper
      }
    }

  }
}
