// Created by eric_horacek on 4/6/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - HeightInvalidatingBarView

/// A bar view that's able to animatedly invalidate its height within an enclosing `BarStackView`.
public protocol HeightInvalidatingBarView: UIView {
  /// The height invalidation context that can be used to animatedly resize the `BarStackView` that
  /// the bar is enclosed within.
  var heightInvalidationContext: BarHeightInvalidationContext? { get set }
}

// MARK: Defaults

extension HeightInvalidatingBarView {
  @nonobjc
  public var heightInvalidationContext: BarHeightInvalidationContext? {
    get { objc_getAssociatedObject(self, &Keys.context) as? BarHeightInvalidationContext }
    set { objc_setAssociatedObject(self, &Keys.context, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
}

// MARK: Height Invalidation

extension HeightInvalidatingBarView {
  /// Should be called prior to height invalidation to ensure that other changes are not batched
  /// within the animation transaction.
  public func prepareHeightBarHeightInvalidation() {
    heightInvalidationContext?.barStackSuperview()?.layoutIfNeeded()
  }

  /// Should be called within an animation transaction following a
  /// `prepareHeightBarHeightInvalidation` once the constraints affecting the height have been
  /// updated.
  public func invalidateBarHeight() {
    heightInvalidationContext?.barStackSuperview()?.layoutIfNeeded()
  }
}

// MARK: - BarHeightInvalidationContext

/// A context that's used to animatedly resize an enclosing bar stack view.
public struct BarHeightInvalidationContext {
  /// A closure that returns the enclosing `BarStackView`'s superview.
  let barStackSuperview: () -> UIView?
}

// MARK: - Keys

/// Associated object keys.
private enum Keys {
  static var context = 0
}
