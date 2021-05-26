// Created by Tyler Hedrick on 1/23/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - ConstrainableContainer

/// Wrapper around Constrainable-conforming instances that allows
/// for extensions to be added such as alignment
public struct ConstrainableContainer: Constrainable, AnchoringContainer, EpoxyModeled {

  // MARK: Lifecycle

  public init(_ constrainable: Constrainable) {
    self.constrainable = constrainable
    if let accessibilityAlignmentProviding = constrainable as? AccessibilityAlignmentProviding {
      accessibilityAlignment = accessibilityAlignmentProviding.accessibilityAlignment
    }
    if let horizontalAlignmentProviding = constrainable as? HorizontalAlignmentProviding {
      horizontalAlignment = horizontalAlignmentProviding.horizontalAlignment
    }
    if let paddingProviding = constrainable as? PaddingProviding {
      padding = paddingProviding.padding
    }
    if let verticalAlignmentProviding = constrainable as? VerticalAlignmentProviding {
      verticalAlignment = verticalAlignmentProviding.verticalAlignment
    }
  }

  // MARK: Public

  public private(set) var constrainable: Constrainable

  public var storage = EpoxyModelStorage()

  public var owningView: UIView? {
    constrainable.owningView
  }

  public var layoutFrame: CGRect {
    constrainable.layoutFrame
  }

  /// The underlying constrainable that this container contains
  public var wrapped: Constrainable {
    if let container = constrainable as? ConstrainableContainer {
      return container.wrapped
    }
    return constrainable
  }

  // MARK: AnchoringContainer

  public var anchor: Constrainable { constrainable }

  // MARK: Constrainable

  public var dataID: AnyHashable { constrainable.dataID }

  public func install(in view: UIView) {
    constrainable.install(in: view)
  }

  public func uninstall() {
    constrainable.uninstall()
  }

  public func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? ConstrainableContainer else { return false }
    return other.constrainable.isEqual(to: self.constrainable)
  }

  // MARK: Internal

  /// sets UIViews to have an alpha of 0 which is preferred to setting
  /// isHidden as it allows for smoother animations
  func setHiddenForAnimatedUpdates(_ isHidden: Bool) {
    (wrapped as? UIView)?.alpha = isHidden ? 0 : 1
    (wrapped as? InternalGroup)?.isHidden = isHidden
  }

}

// MARK: AccessibilityAlignmentProviding

extension ConstrainableContainer: AccessibilityAlignmentProviding { }

// MARK: HorizontalAlignmentProviding

extension ConstrainableContainer: HorizontalAlignmentProviding { }

// MARK: PaddingProviding

extension ConstrainableContainer: PaddingProviding { }

// MARK: VerticalAlignmentProviding

extension ConstrainableContainer: VerticalAlignmentProviding { }

extension Constrainable {

  // MARK: Public

  /// Sets the horizontal alignment of this component in the group
  public func horizontalAlignment(_ alignment: VGroup.ItemAlignment?) -> Constrainable {
    var container = _containerOrSelf
    container.horizontalAlignment = alignment
    return container
  }

  /// Sets the vertical alignment of this component in the group
  public func verticalAlignment(_ alignment: HGroup.ItemAlignment?) -> Constrainable {
    var container = _containerOrSelf
    container.verticalAlignment = alignment
    return container
  }

  /// Sets the accessibility alignment of this component in the group
  public func accessibilityAlignment(_ alignment: VGroup.ItemAlignment?) -> Constrainable {
    var container = _containerOrSelf
    container.accessibilityAlignment = alignment
    return container
  }

  /// Sets the padding of this component in the group with the given insets
  public func padding(_ insets: NSDirectionalEdgeInsets) -> Constrainable {
    var container = _containerOrSelf
    container.padding = insets
    return container
  }

  /// Sets the padding of this component in the group on all sides with the provided length
  public func padding(_ length: CGFloat) -> Constrainable {
    padding(.init(top: length, leading: length, bottom: length, trailing: length))
  }

  // MARK: Private

  private var _containerOrSelf: ConstrainableContainer {
    self as? ConstrainableContainer ?? ConstrainableContainer(self)
  }
}
