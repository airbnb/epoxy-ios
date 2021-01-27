// Created by eric_horacek on 8/20/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - BottomBarInstaller

/// Installs a stack of bar views into a view controller.
///
/// The bar stack is constrained to the bottom of the view controller's view.
///
/// The view controller's safe area inset bottom is automatically inset by the height of the bar
/// stack, ensuring that any scrollable content is inset by the height of the bars.
///
/// - SeeAlso: `BarModel`
public final class BottomBarInstaller: NSObject {

  // MARK: Lifecycle

  public init(
    viewController: UIViewController,
    avoidsKeyboard: Bool = false,
    bars: [BarModeling] = [])
  {
    self.viewController = viewController
    keyboardPositionWatcher.enabled = avoidsKeyboard
    installer = .init(viewController: viewController)
    super.init()
    installer.setBars(bars, animated: false)
  }

  // MARK: Public

  /// The container installed in the view controller's view that contains the bar stack.
  ///
  /// Non-`nil` while installed, `nil` otherwise.
  public var container: BottomBarContainer? { installer.container }

  /// Whether this installer's bar stack should be offset to avoid the keyboard as it is shown and
  /// hidden.
  ///
  /// Defaults to `false`.
  public var avoidsKeyboard: Bool {
    get { keyboardPositionWatcher.enabled }
    set { keyboardPositionWatcher.enabled = newValue }
  }

  /// Updates the bar stack to the given bar models, ordered from top to bottom.
  ///
  /// If any model corresponds to the same view as was previously set, the view will be reused and
  /// updated with the new content, optionally animated.
  ///
  /// If any model corresponds to a new view, a new view will be created and inserted, optionally
  /// animated.
  ///
  /// If any model is no longer present, its corresponding view will be removed.
  public func setBars(_ bars: [BarModeling], animated: Bool) {
    installer.setBars(bars, animated: animated)
  }

  /// Installs the bar stack into the associated view controller.
  ///
  /// Should be called once the view controller loads its view. If this installer has no bar models,
  /// no view will be added. A view will only be added once a non-`nil` bar model is set after
  /// installation or if a bar model was set prior to installation.
  public func install() {
    installer.install()
    watchKeyboardPosition(true)
  }

  /// Removes the bar stack from the associated view controller.
  public func uninstall() {
    installer.uninstall()
    watchKeyboardPosition(false)
  }

  // MARK: Internal

  /// The distance that the keyboard overlaps with `viewController.view` from its bottom edge.
  var keyboardOverlap: CGFloat = 0 {
    didSet {
      guard keyboardOverlap != oldValue else { return }
      container?.bottomOffset = keyboardOverlap
    }
  }

  // MARK: Private

  private let keyboardPositionWatcher = KeyboardPositionWatcher()
  private let installer: BarInstaller<BottomBarContainer>

  /// The view controller that will have its `additionalSafeAreaInsets` updated to accommodate for
  /// the bar stack.
  private weak var viewController: UIViewController?

  private func watchKeyboardPosition(_ enable: Bool) {
    guard keyboardPositionWatcher.enabled else { return }

    guard let view = viewController?.viewIfLoaded else {
      EpoxyLogger.shared.assertionFailure(
        "Should only watch keyboard for a view controller that's loaded its view")
      return
    }

    if enable {
      keyboardPositionWatcher.observeOverlap(in: view) { [weak self] overlap in
        self?.keyboardOverlap = overlap
      }
    } else {
      keyboardPositionWatcher.stopObserving(in: view)
    }
  }

}

// MARK: BarCoordinatorPropertyConfigurable

extension BottomBarInstaller: BarCoordinatorPropertyConfigurable {
  public var coordinators: [AnyBarCoordinating] {
    installer.coordinators
  }

  public subscript<Property>(property: BarCoordinatorProperty<Property>) -> Property {
    get { installer[property] }
    set { installer[property] = newValue }
  }

  public func observe<Property>(
    _ property: BarCoordinatorProperty<Property>,
    observer: @escaping (Property) -> Void)
    -> AnyObject
  {
    installer.observe(property, observer: observer)
  }
}
