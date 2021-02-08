// Created by eric_horacek on 8/20/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - BottomBarContainer

/// A view that:
/// - Contains a zero or more bars and updates their layout margins relative to the original safe
///   area insets of its view controller.
/// - Updates the additional bottom safe area insets of its weak view controller reference to be
///   inset by the height of the bar stack.
public final class BottomBarContainer: BarStackView, InternalBarContainer {

  // MARK: Lifecycle

  public init(didUpdateCoordinator: ((AnyBarCoordinating) -> Void)?) {
    super.init(style: .bottomToTop, didUpdateCoordinator: didUpdateCoordinator)

    addSubviews()
    constrainSubviews()
  }

  required public init(style: Style) {
    fatalError("init(style:) has not been implemented")
  }

  // MARK: Public

  public override var center: CGPoint {
    didSet {
      guard center != oldValue else { return }
      // Trigger the insets to be applied in `layoutSubviews`.
      //
      // Calling `updateInsets` directly can cause layout loops. We want the insets to be applied
      // and the end of the runloop.
      setNeedsLayout()
    }
  }

  public var insetBehavior: BarContainerInsetBehavior = .barHeightSafeArea {
    didSet { updateInsetBehavior(from: oldValue) }
  }

  public weak var viewController: UIViewController? {
    didSet { verifyViewController() }
  }

  /// An additional bottom offset that can be applied to this bar stack's position.
  ///
  /// Typically used to offset the bar stack to avoid the keyboard.
  public var bottomOffset: CGFloat = 0 {
    didSet {
      guard bottomOffset != oldValue else { return }
      bottomConstraint?.constant = -bottomOffset
      // Ensure that the bottom offset is applied within the current animation transaction.
      viewController?.view.layoutIfNeeded()
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    updateInsets()
  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if let anchor = superview?.safeAreaLayoutGuide.bottomAnchor {
      superviewSafeAreaSentinel.bottomAnchor.constraint(equalTo: anchor).isActive = true
    }

    if superview == nil {
      // Undo any safe area insets on our way out.
      viewController?.additionalSafeAreaInsets.bottom = 0
    }
  }

  /// Adds this container to a superview, tracking the bottom constraint to use for its bottom offset.
  public func add(to superview: UIView) {
    superview.addSubview(self)

    let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
    bottomConstraint = bottom

    let fitHeight = heightAnchor.constraint(equalToConstant: 0)
    fitHeight.priority = UILayoutPriority(rawValue: UILayoutPriority.fittingSizeLevel.rawValue + 1)

    let overflow = overflowConstraints(in: superview)

    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: superview.leadingAnchor),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor),
      bottom,
      fitHeight,
    ] + overflow)
  }

  /// Removes this container from its superview.
  public func remove() {
    removeFromSuperview()
    bottomConstraint = nil
  }

  // MARK: Internal

  let position = BarContainerPosition.bottom
  var needsScrollViewInsetReset = false
  var needsSafeAreaInsetReset = false

  // MARK: Private

  /// A zero-size hidden view that's constrained to the superview's safe area insets bottom, since
  /// overriding `safeAreaInsetsDidChange` to observe changes to the view controller's safe area
  /// insets can miss changes that affect its safe area insets but not this view's. Whenever this
  /// view is repositioned, we'll get a `layoutSubviews`, where we perform the needed side-effects.
  private let superviewSafeAreaSentinel: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  /// The bottom constraint of this bar stack.
  private var bottomConstraint: NSLayoutConstraint?

  private var additionalSafeAreaInsetsBottom: CGFloat? {
    guard let viewController = viewController else { return nil }
    guard case .barHeightSafeArea = insetBehavior else { return nil }

    // Using the frame.minY here causes us to compute an temporarily invalid safe area inset bottom
    // during animated transitions which causes jumps in the scroll offset as it settles after the
    // animation transaction.
    return max(bottomOffset + frame.height - viewController.originalSafeAreaInsetBottom, 0)
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
  private func updateInsets() {
    updateAdditionalSafeAreaInset(additionalSafeAreaInsetsBottom)

    // If offset from the bottom, use the original layout margins rather than the safe area margins,
    // as the safe area no longer overlaps the bar.
    let margin = (bottomOffset > 0) ? 0 : viewController?.originalSafeAreaInsetBottom ?? 0
    updateScrollViewInset(allScrollViews, margin: margin)
    layoutMargins.bottom = margin
  }

}

// MARK: - UIViewController

extension UIViewController {
  @nonobjc
  fileprivate var originalSafeAreaInsetBottom: CGFloat {
    view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
  }
}
