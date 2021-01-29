// Created by eric_horacek on 10/22/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import FlowCoreUI
import UIKit

// MARK: - PresentationQueue

/// A data structure that maintains a FIFO 2-queue of presentations.
final class PresentationQueue {

  // MARK: Internal

  /// Enqueues the given presentation in this queue, performing it immediately if a transition is
  /// not in progress, otherwise performing once the in-progress transition completes.
  func enqueue(_ model: PresentationModel?, animated: Bool, from presenter: ModalTransitioning) {
    guard !isTransitioning(presenter, animated: animated) else {
      next = .pending(model)
      return
    }

    let changes = Changes.fromCurrent(current, to: model)
    (current, next) = apply(changes, animated: animated, to: presenter)
  }

  // MARK: Private

  /// The current presentation on the queue, or `nil` if there is no current.
  private var current: Presentation?

  /// The next presentation if an transition is currently in progress, to be performed once the
  /// current transition completes.
  private var next = Next.none

  /// Whether a presentation or dismissal transition is in progress.
  private var isTransitioning = false

  /// The current presentation of this queue.
  private struct Presentation {
    var model: PresentationModel
    var state: State

    /// The state that the current presentation can be in: either presented or dismissed.
    enum State {
      case presented(Dismissible)
      case dismissed
    }
  }

  /// The next presentation in this queue.
  public enum Next {
    case none
    case pending(PresentationModel?)
  }

  /// Applies the given changes to the presenter, returning the resulting queue state.
  private func apply(
    _ changes: Changes,
    animated: Bool,
    to presenter: ModalTransitioning)
    -> (current: Presentation?, next: Next)
  {
    switch changes {
    case .none:
      return (current: current, next: next)
    case .dismiss(let dismissible, let model, let newDataID, let next):
      dismiss(dismissible, model: model, newDataID: newDataID, animated: animated, from: presenter)
      return (current: Presentation(model: model, state: .dismissed), next: next)
    case .present(let model):
      let state = display(model, animated: animated, from: presenter)
      return (current: Presentation(model: model, state: state), next: .none)
    }
  }

  /// Dismisses the given model using the provided `Dismissible`.
  private func dismiss(
    _ dismissible: Dismissible,
    model: PresentationModel,
    newDataID: Bool,
    animated: Bool,
    from presenter: ModalTransitioning)
  {
    dismissible.dismiss(animated: animated)
    if let coordinator = presenter.transitionCoordinator {
      transitionAlongside(coordinator, animated: animated, from: presenter) { context in
        if !context.isCancelled {
          if newDataID {
            model.dismiss()
          }
          model.handleDidDismiss()
        }
      }
    }
  }

  /// Displays the given model if it can construct a presentable.
  private func display(
    _ model: PresentationModel,
    animated: Bool,
    from presenter: ModalTransitioning)
    -> Presentation.State
  {
    guard let presentable = model.makePresentable() else {
      return .dismissed
    }

    let dismissible = presentable.present(.init(
      presenting: presenter,
      animated: animated,
      hooks: hooksForDisplay(model, presentable: presentable, animated: animated, from: presenter)))

    // If for some reason the presentation failed (e.g. not in a window), make sure not to errantly
    // set current to a value.
    if let coordinator = presenter.transitionCoordinator {
      transitionAlongside(coordinator, animated: animated, from: presenter)
      return .presented(dismissible)
    } else {
      return .dismissed
    }
  }

  private func hooksForDisplay(
    _ model: PresentationModel,
    presentable: PresentationModel.Presentable,
    animated: Bool,
    from presenter: ModalTransitioning)
    -> ModalTransitions.Hooks
  {
    .init(
      didPresent: model.handleDidPresent,
      didDismiss: { [weak self] in
        // Only update current to dismissed and update the state if it is still at current and
        // presented. This only occurs when a dismissal occurs outside of an `enqueue(...)`
        guard
          let self = self,
          let current = self.current,
          current.model.dataID == model.dataID,
          current.model.isValueEqual(to: model),
          case .presented = current.state else
        {
          return
        }
        self.current?.state = .dismissed
        model.dismiss()
        model.handleDidDismiss()
      })
  }

  /// Whether the given presenter is actively transitioning.
  ///
  /// Has a side-effect of tracking the transition if `true` is returned, which will defer any
  /// submitted presentation models until after the transition.
  private func isTransitioning(_ presenter: ModalTransitioning, animated: Bool) -> Bool {
    guard !isTransitioning else { return true }
    guard let coordinator = presenter.transitionCoordinator else { return false }
    transitionAlongside(coordinator, animated: animated, from: presenter)
    return true
  }

  /// Updates `isTransitioning` alongside the given transition coordinator.
  private func transitionAlongside(
    _ coordinator: UIViewControllerTransitionCoordinator,
    animated: Bool,
    from presenter: ModalTransitioning,
    completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil)
  {
    isTransitioning = true

    coordinator.animate(
      alongsideTransition: nil,
      completion: { [weak self, weak presenter] context in
        completion?(context)
        if let self = self, let presenter = presenter {
          self.stopTransition(presenter: presenter, animated: animated)
        }
      })
  }

  /// Sets `isTransitioning` to `false` at the completion of a transition and enqueues the next
  /// presentation if there is one.
  private func stopTransition(presenter: ModalTransitioning, animated: Bool) {
    guard isTransitioning else { return }
    isTransitioning = false

    if case .pending(let next) = next {
      self.next = .none
      enqueue(next, animated: animated, from: presenter)
    }
  }
}

// MARK: - PresentationQueue.Changes

extension PresentationQueue {
  /// The changes that need to occur to reconcile the current presentation with a pending
  /// presentation.
  private enum Changes {
    /// There are no changes required.
    case none
    /// The current presentation needs to be dismissed, optionally followed by another presentation
    /// once the dismissal has completed.
    case dismiss(Dismissible, PresentationModel, newDataID: Bool, followedBy: Next = .none)
    /// A presentation needs to occur.
    case present(PresentationModel)

    // MARK: Internal

    /// Vends the change to update the current presentation (if there is one) to the given model or
    /// nil.
    static func fromCurrent(_ current: Presentation?, to model: PresentationModel?) -> Changes {
      guard let model = model else {
        if let current = current, case .presented(let dismissible) = current.state {
          return .dismiss(dismissible, current.model, newDataID: true)
        }
        return .none
      }

      if let current = current {
        return from(current, to: model)
      }
      return .present(model)
    }

    // MARK: Private

    /// Vends the change to update the current presentation to the given model.
    private static func from(_ current: Presentation, to model: PresentationModel) -> Changes {
      guard current.model.dataID == model.dataID else {
        return replacing(current, with: model)
      }
      return updating(current, to: model)
    }

    /// Vends the changes to replace the current presentation with the given model when they don't
    /// have the same identity (unequal `dataID`s).
    private static func replacing(_ current: Presentation, with model: PresentationModel) -> Changes {
      switch current.state {
      case .presented(let dismissible):
        return .dismiss(dismissible, current.model, newDataID: true, followedBy: .pending(model))
      case .dismissed:
        return .present(model)
      }
    }

    /// Vends the changes to replace the current presentation with the given model when they have
    /// the same identity (equal `dataID`s).
    private static func updating(_ current: Presentation, to model: PresentationModel) -> Changes {
      switch current.state {
      case .presented(let dismissible):
        if !current.model.isValueEqual(to: model) {
          return .dismiss(dismissible, current.model, newDataID: false, followedBy: .pending(model))
        } else {
          return .none
        }
      case .dismissed:
        return .present(model)
      }
    }
  }
}
