// Created by eric_horacek on 3/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - TopBarContainer

/// A view that:
/// - Contains a zero or more bars and updates their layout margins relative to the original safe
///   area insets of its view controller.
/// - Updates the additional top safe area insets of its view controller to be inset by the height
///   of the bar stack.
public final class TopBarContainer: BarStackView, InternalBarContainer {

  // MARK: Lifecycle

  public required init() {
    super.init()
    zOrder = .firstToLast
    addSubviews()
    constrainSubviews()
  }

  // MARK: Public

  /// The way that the status bar space is treated within a top bar container.
  public enum StatusBarInsetBehavior: Equatable {
    /// The container insets its top bar as if the status bar was visible.
    case visible

    /// The container insets its top bar as if the status bar as hidden. Can optionally maintain the
    /// previous top inset where the status bar was previously visible.
    case hidden(roomToReappear: Bool)
  }

  /// The `TopBarInstaller` that manages this `TopBarContainer`
  public internal(set) weak var barInstaller: TopBarInstaller?

  public override var center: CGPoint {
    didSet {
      guard center != oldValue else { return }
      // Trigger the insets to be applied in `layoutSubviews`.
      //
      // Calling `updateInsets` directly can cause layout loops. We want the insets to be applied
      // at the end of the runloop.
      setNeedsLayout()
    }
  }

  public var insetBehavior: BarContainerInsetBehavior = .barHeightSafeArea {
    didSet { updateInsetBehavior(from: oldValue) }
  }

  public var insetMargins: Bool = true {
    didSet {
      guard insetMargins != oldValue else { return }
      setNeedsLayout()
    }
  }

  /// The behavior of the status bar when it's hidden.
  ///
  /// Can be called from within an animation block to animate changes to the hiding behavior.
  public var statusBarInsetBehavior: StatusBarInsetBehavior = .visible {
    didSet {
      guard statusBarInsetBehavior != oldValue else { return }
      updateStatusBarInsetBehavior()
    }
  }

  /// Whether this top bar container treats the status bar as hidden.
  public var isStatusBarHidden: Bool {
    if case .visible = statusBarInsetBehavior { return false }
    return true
  }

  public weak var viewController: UIViewController? {
    didSet { verifyViewController() }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    updateInsets()
  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if let anchor = superview?.safeAreaLayoutGuide.topAnchor {
      superviewSafeAreaSentinel.topAnchor.constraint(equalTo: anchor).isActive = true
    }

    if superview == nil {
      // Undo any safe area insets on our way out.
      viewController?.additionalSafeAreaInsets.top = 0
    }
  }

  /// Adds this container to a superview.
  public func add(to superview: UIView) {
    superview.addSubview(self)

    let fitHeight = heightAnchor.constraint(equalToConstant: 0)
    fitHeight.priority = UILayoutPriority(rawValue: UILayoutPriority.fittingSizeLevel.rawValue + 1)

    let overflow = overflowConstraints(in: superview)

    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor),
      fitHeight,
    ] + overflow)
  }

  /// Removes this container from its superview.
  public func remove() {
    removeFromSuperview()
  }

  // MARK: Internal

  let position = BarContainerPosition.top
  var needsScrollViewInsetReset = false
  var needsSafeAreaInsetReset = false

  // MARK: Private

  /// A flag indicating whether a scroll view is currently scrolled to its top or bottom edge within
  /// the view controller's view.
  private enum ScrollViewEdge {
    case top, bottom
  }

  /// An extra top margin applied to the layout margins.
  ///
  /// Used to maintain space when the status bar is hidden.
  private var extraLayoutMarginsTop: CGFloat = 0

  /// A zero-size hidden view that's constrained to the superview's safe area insets top, since
  /// overriding `safeAreaInsetsDidChange` to observe changes to the view controller's safe area
  /// insets can miss changes that affect its safe area insets but not this view's. Whenever this
  /// view is repositioned, we'll get a `layoutSubviews`, where we perform the needed side-effects.
  private let superviewSafeAreaSentinel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  private var additionalSafeAreaInsetsTop: CGFloat? {
    guard let viewController = viewController else { return nil }
    guard case .barHeightSafeArea = insetBehavior else { return nil }

    // Using the frame.maxY here causes us to compute an temporarily invalid safe area inset top
    // during animated transitions which causes jumps in the scroll offset as it settles after the
    // animation transaction.
    return max(frame.height - viewController.originalSafeAreaInsetTop, 0)
  }

  /// Returns the scroll views that are scrolled to an edge in the `viewController`.
  private var scrollViewsAtEdge: [(UIScrollView, ScrollViewEdge)] {
    allScrollViews.compactMap { scrollView in
      let offset = scrollView.contentOffset.y
      // Prioritize keeping the scroll view at its top edge over the bottom edge.
      if offset <= scrollView.topContentOffset { return (scrollView, .top) }
      if offset >= scrollView.bottomContentOffset { return (scrollView, .bottom) }
      return nil
    }
  }

  private var layoutMarginsTop: CGFloat {
    guard let viewController = viewController else { return 0 }
    return viewController.originalSafeAreaInsetTop
  }

  private func addSubviews() {
    addSubview(superviewSafeAreaSentinel)
  }

  private func constrainSubviews() {
    NSLayoutConstraint.activate([
      superviewSafeAreaSentinel.leftAnchor.constraint(equalTo: leftAnchor),
      superviewSafeAreaSentinel.widthAnchor.constraint(equalToConstant: 0),
      superviewSafeAreaSentinel.heightAnchor.constraint(equalToConstant: 0),
    ])
  }

  /// Updates the view controller insets (either safe area or scroll view content inset) in response
  /// to the safe area, center, or bounds changing.
  ///
  /// Additionally keeps the scroll views pinned to their current offsets during the inset changes.
  private func updateInsets() {
    let scrollViewsAtEdge = self.scrollViewsAtEdge

    updateAdditionalSafeAreaInset(additionalSafeAreaInsetsTop)

    let margin = layoutMarginsTop + extraLayoutMarginsTop
    updateScrollViewInset(allScrollViews, margin: margin)
    setLayoutMargin(margin)

    // Make sure to keep any scroll views at top/bottom when adjusting content/safe area insets.
    scrollToEdge(scrollViewsAtEdge)
  }

  /// Scrolls the provided scroll views back to the edge that they were previously scrolled to prior
  /// to the layout margins change, non-animatedly.
  private func scrollToEdge(_ scrollViewsAtEdge: [(UIScrollView, ScrollViewEdge)]) {
    for (scrollView, edge) in scrollViewsAtEdge {
      switch edge {
      case .top:
        scrollView.contentOffset.y = scrollView.topContentOffset
      case .bottom:
        scrollView.contentOffset.y = scrollView.bottomContentOffset
      }
    }
  }

  private func updateStatusBarInsetBehavior() {
    viewController?.setNeedsStatusBarAppearanceUpdate()

    if case .hidden(let roomToReappear) = statusBarInsetBehavior, roomToReappear {
      // If we want room to reappear, add in extra top margins equal to the size that disappeared
      // (the difference between the previous margins and new margins with the status bar hidden).
      extraLayoutMarginsTop = max(layoutMargins.top - layoutMarginsTop, 0)
    } else {
      extraLayoutMarginsTop = 0
    }

    // For re-layout of both the view controller's view as well as the view controller's view. If
    // this update is occurring within an animation block, this ensures all changes to insets are
    // animated as part of it.
    //
    // This will have a side-effect of applying the new extra top layout margins.
    setNeedsLayout()
    viewController?.view.setNeedsLayout()
    viewController?.view.layoutIfNeeded()
  }

}

// MARK: - UIViewController

extension UIViewController {
  @nonobjc
  fileprivate var originalSafeAreaInsetTop: CGFloat {
    view.safeAreaInsets.top - additionalSafeAreaInsets.top
  }
}

// MARK: - UIScrollView

extension UIScrollView {
  /// The content offset at which this scroll view is scrolled to its top.
  @nonobjc
  fileprivate var topContentOffset: CGFloat {
    -adjustedContentInset.top
  }

  /// The content offset at which this scroll view is scrolled to its bottom.
  @nonobjc
  fileprivate var bottomContentOffset: CGFloat {
    max(contentSize.height - bounds.height + adjustedContentInset.bottom, topContentOffset)
  }
}
