// Created by eric_horacek on 11/3/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - TopBarInstaller

/// Installs a stack of bar views at the top of a view controller's view.
///
/// The bar stack is constrained to the top of the view controller's view.
///
/// The view controller's safe area inset top is automatically inset by the height of the bar stack,
/// ensuring that any scrollable content is inset by the height of the bars.
///
/// - SeeAlso: `BarModel`
public final class TopBarInstaller: NSObject {

  // MARK: Lifecycle

  public init(
    viewController: UIViewController,
    bars: [BarModeling] = [],
    configuration: BarInstallerConfiguration = .shared)
  {
    self.viewController = viewController
    installer = .init(viewController: viewController, configuration: configuration)
    super.init()

    // We don't call `setNeedsStatusBarAppearanceUpdate` through `self.setBars(...)` here since it
    // can blow the stack by re-entering this initializer through the view controller's status bar
    // appearance accessors, which call through to the lazy top bar installer property, etc.
    installer.setBars(bars, animated: false)
  }

  public convenience init(
    viewController: UIViewController,
    @BarModelBuilder bars: () -> [BarModeling])
  {
    self.init(viewController: viewController, bars: bars())
  }

  // MARK: Public

  /// The container installed in the view controller's view that contains the bar stack.
  ///
  /// Non-`nil` while installed, `nil` otherwise.
  public var container: TopBarContainer? { installer.container }

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

    // A new set of models may result in an update to the status bar.
    viewController?.setNeedsStatusBarAppearanceUpdate()
  }

  /// Installs the bar stack into the associated view controller.
  ///
  /// Should be called once the view controller loads its view. If this installer has no bar model,
  /// no view will be added. A view will only be added once a non-nil bar model is set after
  /// installation or if a bar model was set prior to installation.
  public func install() {
    installer.install()
  }

  /// Removes the bar stack from the associated view controller.
  public func uninstall() {
    installer.uninstall()
  }

  // MARK: Internal

  let installer: BarInstaller<TopBarContainer>

  // MARK: Private

  /// The view controller that will have its `additionalSafeAreaInsets` updated to accommodate for
  /// the bar stack.
  private weak var viewController: UIViewController?

}

// MARK: BarCoordinatorPropertyConfigurable

extension TopBarInstaller: BarCoordinatorPropertyConfigurable {
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
