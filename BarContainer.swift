// Created by eric_horacek on 5/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

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

// MARK: InternalBarContainer

/// The internal behavior of a `BarContainer`.
protocol InternalBarContainer: BarContainer {
  /// The position of this bar container within its view controller's view.
  var position: BarContainerPosition { get }

  /// Whether the scroll view insets should be removed on the next content inset update.
  var needsScrollViewInsetReset: Bool { get set }
}

// MARK: - BarContainerPosition

/// The positions that a bar container can be placed at.
enum BarContainerPosition {
  case top
  case bottom

  /// They key path for the relevant
  var inset: WritableKeyPath<UIEdgeInsets, CGFloat> {
    switch self {
    case .top: return \.top
    case .bottom: return \.bottom
    }
  }

  func edge(_ rect: CGRect) -> CGFloat {
    switch self {
    case .top: return rect.minY
    case .bottom: return rect.maxY
    }
  }
}

// MARK: - InternalBarContainer

extension InternalBarContainer {
  /// All immediate scroll view subviews of this bar container's view controller.
  var allScrollViews: [UIScrollView] {
    guard let viewController = viewController else { return [] }
    return viewController.view.subviews.compactMap { $0 as? UIScrollView }
  }

  /// Handles the inset behavior being updated from a previous value.
  ///
  /// Updates `shouldResetScrollInsets` based on the old inset behavior.
  func updateInsetBehavior(from oldValue: BarContainerInsetBehavior) {
    guard insetBehavior != oldValue else { return }

    needsScrollViewInsetReset = (oldValue == .barHeightContentInset)

    // Trigger the insets to be applied in `layoutSubviews`.
    setNeedsLayout()
  }

  // Adjusts the content inset of the given scroll views based on the `insetBehavior`.
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

      /// The adjustment that's already applied to the content inset via the safe area.
      let adjustment = scrollView.adjustedContentInset[keyPath: position.inset]
        - scrollView.contentInset[keyPath: position.inset]

      let contentInset = max(frame.height - adjustment, margin, 0)

      let scrollInset: CGFloat
      if #available(iOS 13.0, *), scrollView.automaticallyAdjustsScrollIndicatorInsets {
        scrollInset = max(contentInset - safeAreaInsets[keyPath: position.inset], 0)
      } else {
        scrollInset = contentInset
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
}
