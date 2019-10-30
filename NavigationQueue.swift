// Created by eric_horacek on 10/23/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
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

    let next = nextFrom(models: models, previous: current)
    current = applyNext(next, from: current, animated: animated, to: interface)
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
      self.current = applyPopped(popped, from: current)
      stopTransition(interface: interface, animated: animated)
      return
    }

    isTransitioning = true
    coordinator.animate(
      alongsideTransition: nil,
      completion: { [weak self, weak interface] context in
        guard let self = self, let interface = interface else { return }
        if !context.isCancelled {
          self.current = self.applyPopped(popped, from: current)
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
  private func nextFrom(models: [NavigationModel], previous: NavigationStack?)
    -> (stack: NavigationStack, changes: NavigationStack.AppliedChanges)
  {
    guard var next = previous else {
      let stack = NavigationStack(models: models)
      return (stack: stack, changes: .init(removals: [], additions: stack.added))
    }
    let changes = next.applyModels(models)
    return (stack: next, changes: changes)
  }

  /// Returns the next navigation stack after performing any necessary side-effects to apply it.
  private func applyNext(
    _ next: (stack: NavigationStack, changes: NavigationStack.AppliedChanges),
    from previous: NavigationStack?,
    animated: Bool,
    to interface: NavigationInterface)
    -> NavigationStack
  {
    interface.setStack(next.stack.addedViewControllers, animated: animated)

    // We want to make sure not to capture any removed view controllers.
    let notify = { [changes = next.changes, next = next.stack.addedTop, prev = previous?.addedTop?.model] in
      changes.removals.forEach { $0.handleDidRemove() }
      changes.additions.forEach { $0.model.handleDidAdd($0.viewController) }
      NavigationStack.Added.handleTopChange(from: prev, to: next)
    }

    if let coordinator = interface.transitionCoordinator {
      isTransitioning = true

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
      stopTransition(interface: interface, animated: animated)
    }

    return next.stack
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
      completion: { [weak self, weak interface] context in
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
    from current: NavigationStack)
    -> NavigationStack
  {
    var next = current
    var removals = [NavigationModel]()

    for element in popped {
      guard let index = next.viewControllers.firstIndex(where: { $0 === element }) else {
        assertionFailure("\(element) not in \(next.viewControllers), this is programmer error.")
        continue
      }

      let model = next.models[index]
      next.viewControllers[index] = nil
      removals.append(model)
    }

    removals.forEach { $0.handleDidRemove() }

    NavigationStack.Added.handleTopChange(from: current.addedTop?.model, to: next.addedTop)

    return next
  }

}

// MARK: - NavigationStack

/// A navigation stack on the queue.
private struct NavigationStack {

  // MARK: Lifecycle

  init(models: [NavigationModel]) {
    self.models = models
    viewControllers = models.map { $0.makeViewController?() }
  }

  // MARK: Internal

  /// The models within this navigation stack.
  var models: [NavigationModel]

  /// The view controllers within this navigation stack, with indexes matching `models`.
  var viewControllers: [UIViewController?]

  /// The view controllers that are added to this stack. Indexes do not match `models`, as some
  /// models may not be visible.
  var addedViewControllers: [UIViewController] {
    return viewControllers.compactMap { $0 }
  }

  /// A model that has been added to the navigation stack and its corresponding view controller.
  struct Added {
    var model: NavigationModel
    var viewController: UIViewController

    static func handleTopChange(from previous: NavigationModel?, to next: Added?) {
      switch (previous: previous, next: next) {
      case (.some(let previous), .some(let next)):
        if previous.dataID != next.model.dataID {
          previous.handleDidHide()
          next.model.handleDidShow(next.viewController)
        }
      case (nil, .some(let next)):
        next.model.handleDidShow(next.viewController)
      case (.some(let previous), nil):
        previous.handleDidHide()
      case (nil, nil):
        break
      }
    }
  }

  /// Returns the added models and their corresponding view controllers in this stack.
  var added: [Added] {
    return zip(models, viewControllers).compactMap { modelAndViewController in
      modelAndViewController.1.map { viewController in
        Added(model: modelAndViewController.0, viewController: viewController)
      }
    }
  }

  /// Returns the topmost added model and its corresponding view controller of this stack, else
  /// `nil` if there is none.
  var addedTop: Added? {
    return added.last
  }

  /// The additions and removals resulting from applying a new set of models to this stack.
  struct AppliedChanges {
    var removals: [NavigationModel]
    var additions: [Added]
  }

  /// Applies the given models to this navigation stack, returning the navigation models that were
  /// removed and added from the stack.
  mutating func applyModels(_ newModels: [NavigationModel]) -> AppliedChanges {
    var newViewControllers = viewControllers
    let changeset = newModels.makeChangeset(from: models)
    var changes = AppliedChanges(removals: [], additions: [])

    for (from, to) in changeset.updates {
      let toModel = newModels[to]
      let toViewController = toModel.makeViewController?()
      newViewControllers[from] = toViewController

      switch (from: viewControllers[from], to: toViewController) {
      case (from: .some, to: nil):
        changes.removals.append(models[from])
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
      let viewController = model.makeViewController?()
      newViewControllers.insert(viewController, at: index)
      if let viewController = viewController {
        changes.additions.append(.init(model: model, viewController: viewController))
      }
    }

    for (from, to) in changeset.moves {
      newViewControllers[to] = viewControllers[from]
    }

    models = newModels
    viewControllers = newViewControllers
    return changes
  }
}
