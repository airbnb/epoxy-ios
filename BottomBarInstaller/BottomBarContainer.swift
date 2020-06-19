// Created by eric_horacek on 8/20/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// A view that:
/// - Contains a zero or more bars and updates their layout margins relative to the original safe
///   area insets of its view controller.
/// - Updates the additional bottom safe area insets of its weak view controller reference to be
///   inset by the height of the bar stack.
public final class BottomBarContainer: BarStackView, FixedBarView, InternalBarContainer {

  // MARK: Lifecycle

  public init(
    willDisplayBar: ((_ bar: UIView) -> Void)? = nil,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? = nil)
  {
    super.init(
      zOrder: .bottomToTop,
      willDisplayBar: willDisplayBar,
      didUpdateCoordinator: didUpdateCoordinator)

    addSubviews()
    constrainSubviews()
  }

  // MARK: UIView

  public override func layoutSubviews() {
    super.layoutSubviews()

    viewController?.additionalSafeAreaInsets.bottom = additionalSafeAreaInsetsBottom

    // If offset from the bottom, use the original layout margins rather than the safe area margins,
    // as the safe area no longer overlaps the bar.
    let margin = (bottomOffset > 0) ? 0 : viewController?.originalSafeAreaInsetBottom ?? 0
    updateScrollViewInset(allScrollViews, margin: margin)
    layoutMargins.bottom = margin
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

  // MARK: Public

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

  // MARK: Private

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

  /// The bottom constraint of this bar stack.
  private var bottomConstraint: NSLayoutConstraint?

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

  private var additionalSafeAreaInsetsBottom: CGFloat {
    guard let viewController = viewController else { return 0 }
    guard case .barHeightSafeArea = insetBehavior else { return 0 }

    // Using the frame.minY here causes us to compute an temporarily invalid safe area inset bottom
    // during animated transitions which causes jumps in the scroll offset as it settles after the
    // animation transaction.
    return max(bottomOffset + frame.height - viewController.originalSafeAreaInsetBottom, 0)
  }
}

// MARK: - UIViewController

private extension UIViewController {
  @nonobjc
  var originalSafeAreaInsetBottom: CGFloat {
    view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
  }
}
