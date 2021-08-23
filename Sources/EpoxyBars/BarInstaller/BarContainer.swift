// Created by eric_horacek on 5/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - BarContainer

/// A container of bar views that insets its view controller's safe area insets.
public protocol BarContainer: BarStackView {
  /// The coordinators for each of the bars within this stack, ordered from top to bottom.
  var coordinators: [AnyBarCoordinating] { get }

  /// The view controller that will have its `additionalSafeAreaInsets` updated to accommodate for
  /// the bar view.
  var viewController: UIViewController? { get set }

  /// Adds this container to the given superview.
  func add(to superview: UIView)

  /// Removes this container from its current superview.
  func remove()

  /// The inset behavior of this bar container.
  var insetBehavior: BarContainerInsetBehavior { get set }
}

// MARK: - BarContainerInsetBehavior

/// The inset behavior of a bar container.
public enum BarContainerInsetBehavior: Equatable {
  /// Additionally insets the safe area inset of the view controller by the height of the bars
  /// contained by this container.
  ///
  /// This is the default behavior.
  case barHeightSafeArea

  /// Updates the content inset of any scroll views that are immediate subviews of the view
  /// controller's view by the height of the bars contained by this container.
  ///
  /// Typically used in combination with a `UIScrollView.ContentInsetAdjustmentBehavior` of
  /// `never` if scrollable content of the opposite bar container needs to underlap the safe area.
  case barHeightContentInset

  /// Does not additionally inset the safe area or content insets of the view controller in any way.
  /// Typically used in cases where the top bar is fully transparent.
  case none
}

// MARK: - InternalBarContainer

/// The internal behavior of a `BarContainer`.
protocol InternalBarContainer: BarContainer {

  /// A closure that's called after a bar coordinator has been created.
  var didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? { get set }

  /// The position of this bar container within its view controller's view.
  var position: BarContainerPosition { get }

  /// Whether the scroll view insets should be removed on the next content inset update.
  var needsScrollViewInsetReset: Bool { get set }

  /// Whether or not the additional safe area insets need to be reset to 0
  var needsSafeAreaInsetReset: Bool { get set }

  /// Whether or not this bar container should apply `layoutMargins`
  /// derived from the `viewController`'s `safeAreaInsets` to its bars.
  ///  - `true` by default.
  var insetMargins: Bool { get set }
}

// MARK: - BarContainerPosition

/// The positions that a bar container can be placed at.
enum BarContainerPosition {
  /// The bar container is fixed at the top of a view.
  case top
  /// The bar container is fixed at the bottom of a view.
  case bottom

  // MARK: Internal

  /// They key path for the component of a `UIEdgeInsets` that corresponds to this position.
  var inset: WritableKeyPath<UIEdgeInsets, CGFloat> {
    switch self {
    case .top: return \.top
    case .bottom: return \.bottom
    }
  }

  /// They y position of the edge of the given `CGRect` that corresponds to this position.
  func edge(_ rect: CGRect) -> CGFloat {
    switch self {
    case .top: return rect.minY
    case .bottom: return rect.maxY
    }
  }
}

// MARK: - InternalBarContainer

extension InternalBarContainer {

  // MARK: Internal

  /// All immediate scroll view subviews of this bar container's view controller.
  var allScrollViews: [UIScrollView] {
    guard let viewController = viewController else { return [] }
    return viewController.view.subviews.compactMap { $0 as? UIScrollView }
  }

  /// The constraints necessary to ensure that the bar stacks in this view shouldn't overflow into
  /// the opposite stack or extend past the screen edge.
  func overflowConstraints(in view: UIView) -> [NSLayoutConstraint] {
    var constraints = [screenEdgeConstraint(in: view)]

    // It's the responsibility of the last added bar to also constrain its opposite bar to itself.
    if let other = otherBarContainer(in: view) {
      constraints.append(other.constraintToOpposite(self))
      constraints.append(constraintToOpposite(other))
    }

    return constraints
  }

  /// Handles the inset behavior being updated from a previous value.
  ///
  /// Updates `shouldResetScrollInsets` based on the old inset behavior.
  func updateInsetBehavior(from oldValue: BarContainerInsetBehavior) {
    guard insetBehavior != oldValue else { return }

    needsScrollViewInsetReset = (oldValue == .barHeightContentInset)

    // Reset the safe area insets back to 0 when the `insetBehavior`
    // changes from `.barHeightSafeArea` to something else, like `.none`
    //  - We only want to reset the safe area insets to 0 when the `insetBehavior` changes.
    //    Setting it on every layout pass would overwrite any values configured by the VC's owner.
    needsSafeAreaInsetReset = (oldValue == .barHeightSafeArea)

    // Trigger the insets to be applied in `layoutSubviews`.
    setNeedsLayout()
  }

  // Adjusts the content inset of the given scroll views based on the `insetBehavior`.
  //
  // Should be called whenever the frame (bounds.size/center) or safe area of this bar changes.
  func updateScrollViewInset(_ scrollViews: [UIScrollView], margin: CGFloat) {
    guard insetBehavior == .barHeightContentInset || needsScrollViewInsetReset else { return }

    for scrollView in scrollViews {
      // Only inset scroll views at the same edge at this bar container.
      guard position.edge(frame) == position.edge(scrollView.frame) else { continue }

      if needsScrollViewInsetReset {
        // Reset insets to 0 if needed to allow them to be customized again without being clobbered.
        scrollView.contentInset[keyPath: position.inset] = 0
        scrollView.horizontalScrollIndicatorInsets[keyPath: position.inset] = 0
        scrollView.verticalScrollIndicatorInsets[keyPath: position.inset] = 0
        continue
      }

      // The size of the inset that we're trying to apply.
      let inset = max(frame.height, margin)

      /// Calculate the content inset by subtracting out the adjustment that's already applied to
      /// the content inset via the safe area.
      let adjustment = scrollView.adjustedContentInset[keyPath: position.inset]
        - scrollView.contentInset[keyPath: position.inset]
      let contentInset = max(inset - adjustment, 0)

      /// Calculate the scroll inset by subtracting out the adjustment that's already applied to
      /// the scroll inset via the safe area.
      let scrollInset: CGFloat
      if scrollView.automaticallyAdjustsScrollIndicatorInsets {
        scrollInset = max(inset - safeAreaInsets[keyPath: position.inset], 0)
      } else {
        scrollInset = inset
      }

      scrollView.contentInset[keyPath: position.inset] = contentInset
      scrollView.horizontalScrollIndicatorInsets[keyPath: position.inset] = scrollInset
      scrollView.verticalScrollIndicatorInsets[keyPath: position.inset] = scrollInset
    }

    // Now that we've reset the insets, make sure we don't do it again next time.
    if needsScrollViewInsetReset {
      needsScrollViewInsetReset = false
    }
  }

  // Adjusts the additional safe area inset of the view controller based on the `insetBehavior`.
  func updateAdditionalSafeAreaInset(_ inset: CGFloat?) {
    if let inset = inset {
      viewController?.additionalSafeAreaInsets[keyPath: position.inset] = inset
    } else if needsSafeAreaInsetReset {
      viewController?.additionalSafeAreaInsets[keyPath: position.inset] = 0
      needsSafeAreaInsetReset = false
    }
  }

  /// Asserts that the view controller this bar container was added to is in a valid state.
  func verifyViewController() {
    guard let viewController = viewController else { return }

    EpoxyLogger.shared.assert(
      viewController.isViewLoaded,
      "The view controller's view should be loaded when it has a bar container added")

    // Bar pinning won't work within a scroll view, e.g. with `UITableViewController`.
    EpoxyLogger.shared.assert(
      !(viewController.view is UIScrollView),
      "The view controller's view must not be a scroll view. Nest any scroll views in a container.")
  }

  /// Sets the `layoutMargin` corresponding to the container's `position`
  func setLayoutMargin(_ margin: CGFloat) {
    guard insetMargins else { return }
    layoutMargins[keyPath: position.inset] = margin
  }

  // MARK: Private

  private func screenEdgeConstraint(in view: UIView) -> NSLayoutConstraint {
    switch position {
    case .top:
      return bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
    case .bottom:
      return topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
    }
  }

  private func constraintToOpposite(_ opposite: BarContainer) -> NSLayoutConstraint {
    switch position {
    case .top:
      return bottomAnchor.constraint(lessThanOrEqualTo: opposite.topAnchor)
    case .bottom:
      return topAnchor.constraint(greaterThanOrEqualTo: opposite.bottomAnchor)
    }
  }

  private func otherBarContainer(in view: UIView) -> InternalBarContainer? {
    let others = view.subviews.compactMap { subview in
      subview == self ? nil : subview as? InternalBarContainer
    }

    EpoxyLogger.shared.assert(
      others.count < 2,
      "Found two or more bar containers in \(viewController as Any): \(others + [self]). This is programmer error.")

    return others.first
  }
}
