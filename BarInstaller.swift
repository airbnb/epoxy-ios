// Created by eric_horacek on 11/3/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - BarContainer

/// A container of bar views that insets its view controller's safe area insets.
public protocol BarContainer: BarStackView {
  /// Creates this container with a closure that's invoked when a bar is about to be displayed.
  init(
    willDisplayBar: ((_ bar: UIView) -> Void)?,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)?)

  var coordinators: [AnyBarCoordinating] { get }

  /// The view controller that will have its `additionalSafeAreaInsets` updated to accommodate for
  /// the bar view.
  var viewController: UIViewController? { get set }

  /// Adds this container to the given superview.
  func add(to superview: UIView)

  /// Removes this container from its current superview.
  func remove()
}

// MARK: - BarInstaller

/// An installer that's capable of installing a stack of fixed bars within a view controller.
public final class BarInstaller<Container: BarContainer> {

  // MARK: Lifecycle

  public init(
    viewController: UIViewController?,
    willDisplayBar: ((_ bar: UIView) -> Void)? = nil,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? = nil)
  {
    self.viewController = viewController
    self.willDisplayBar = willDisplayBar
    self.didUpdateCoordinator = didUpdateCoordinator
  }

  // MARK: Public

  /// The container that the bars are within.
  ///
  /// Non-nil while installed, nil otherwise.
  public private(set) var container: Container?

  /// The current bar models.
  public private(set) var models: [BarModeling] = []

  /// Updates the bars to the given models, ordered from top to bottom.
  ///
  /// If any model correponds to the same view as was previously set, the view will be reused and
  /// updated with the new content, optionally animated.
  ///
  /// If any model corresponds to a new bar, a new bar view will be created and inserted,
  /// optionally animated.
  ///
  /// If any model is no longer present, its corresponding view will be removed.
  public func setModels(_ models: [BarModeling], animated: Bool) {
    guard installed, let view = viewController?.viewIfLoaded else {
      self.models = models
      return
    }

    setModels(models, animated: animated, in: view)
  }

  /// Installs the bars into the associated view controller.
  ///
  /// Should be called once the view controller loads its view. If this installer has no bar model,
  /// no view will be added. A view will only be added once a non-nil bar model is set after
  /// installation or if a bar model was set prior to installation.
  public func install() {
    installed = true

    guard let view = viewController?.viewIfLoaded else {
      assertionFailure("A bar should only be installed on a view controller that's loaded its view")
      return
    }

    setModels(models, animated: false, in: view)
  }

  /// Removes the the bars from the associated view controller.
  public func uninstall() {
    uninstallContainer()
    installed = false
  }

  // MARK: Private

  /// A stored value for an installer's coordinators.
  private struct StoredCoordinatorProperty {
    /// The current type-erased property value.
    var value: Any
    /// A closure that can be used to update a coordinator's property to the value.
    var updateCoordinator: (_ coordinator: AnyObject, _ value: Any) -> Void
  }

  /// A closure that's invoked when a bar is about to be displayed.
  private let willDisplayBar: ((_ bar: UIView) -> Void)?

  /// A closure that's called after a coordinator has been created.
  private let didUpdateCoordinator: ((AnyBarCoordinating) -> Void)?

  /// The view controller that will have its `additionalSafeAreaInsets` updated to accommodate for
  /// the bar view.
  private weak var viewController: UIViewController?

  /// Whether this installer has been installed on its view controller's view, meaning that it's
  /// safe to add a container as a subview.
  private var installed = false

  private var storage = [BarCoordinatorPropertyKey: StoredCoordinatorProperty]()

  /// Updates the models to the given collection, installing the container if needed.
  private func setModels(_ models: [BarModeling], animated: Bool, in view: UIView) {
    self.models = models

    guard let container = container else {
      installContainer(in: view, with: models, animated: animated)
      return
    }

    container.setModels(models, animated: animated)
  }

  private func installContainer(in view: UIView, with models: [BarModeling], animated: Bool) {
    let container = Container(
      willDisplayBar: willDisplayBar,
      didUpdateCoordinator: { [weak self] coordinator in
        self?.updateCoordinatorProperties(coordinator)
        self?.didUpdateCoordinator?(coordinator)
      })
    container.add(to: view)
    container.viewController = viewController
    container.setModels(models, animated: animated)
    self.container = container
  }

  private func updateCoordinatorProperties(_ coordinator: AnyBarCoordinating) {
    for value in storage.values {
      value.updateCoordinator(coordinator, value.value)
    }
  }

  private func uninstallContainer() {
    guard let container = container else { return }
    container.remove()
    self.container = nil
  }
}

// MARK: BarCoordinatorPropertyConfigurable

extension BarInstaller: BarCoordinatorPropertyConfigurable {
  public subscript<Property>(property: BarCoordinatorProperty<Property>) -> Property {
    get {
      (storage[property.key]?.value as? Property) ?? property.default()
    }
    set {
      storage[property.key] = .init(value: newValue, updateCoordinator: property.update)
      container?.coordinators.forEach { property.update($0, newValue) }
    }
  }
}
