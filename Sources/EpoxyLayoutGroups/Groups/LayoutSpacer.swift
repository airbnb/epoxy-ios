// Created by Tyler Hedrick on 1/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// Used inside of an HGroup or VGroup to space out components
/// e.g.:
/// let vGroup = VGroup {
///   titleLabel
///   LayoutSpacer(fixedHeight: 16)
///   subtitleLabel
/// }
public final class LayoutSpacer: UILayoutGuide, Constrainable {

  // MARK: Lifecycle

  public init(style: Style) {
    self.style = style
    super.init()
  }

  public convenience init(
    minHeight: CGFloat? = nil,
    minWidth: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    maxWidth: CGFloat? = nil,
    fixedHeight: CGFloat? = nil,
    fixedWidth: CGFloat? = nil)
  {
    self.init(
      style: .init(
        minHeight: minHeight,
        minWidth: minWidth,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        fixedHeight: fixedHeight,
        fixedWidth: fixedWidth))
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public struct Style: Hashable {

    // MARK: Lifecycle

    public init(
      minHeight: CGFloat? = nil,
      minWidth: CGFloat? = nil,
      maxHeight: CGFloat? = nil,
      maxWidth: CGFloat? = nil,
      fixedHeight: CGFloat? = nil,
      fixedWidth: CGFloat? = nil)
    {
      self.minHeight = minHeight
      self.minWidth = minWidth
      self.maxHeight = maxHeight
      self.maxWidth = maxWidth
      self.fixedHeight = fixedHeight
      self.fixedWidth = fixedWidth
    }

    // MARK: Public

    public var minHeight: CGFloat?
    public var minWidth: CGFloat?
    public var maxHeight: CGFloat?
    public var maxWidth: CGFloat?
    public var fixedHeight: CGFloat?
    public var fixedWidth: CGFloat?
  }

  public let style: Style

  // MARK: Constrainable

  public var firstBaselineAnchor: NSLayoutYAxisAnchor { topAnchor }
  public var lastBaselineAnchor: NSLayoutYAxisAnchor { bottomAnchor }

  public func install(in view: UIView) {
    view.addLayoutGuide(self)
    installConstraints()
  }

  public func uninstall() {
    owningView?.removeLayoutGuide(self)
  }

  public func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? LayoutSpacer else { return false }
    return other.style == style
  }

  // MARK: Private

  private var constraints: [NSLayoutConstraint] = []

  private func installConstraints() {
    NSLayoutConstraint.deactivate(constraints)
    constraints = []

    // Equality constraints
    if let fixedHeight = style.fixedHeight {
      constraints.append(heightAnchor.constraint(equalToConstant: fixedHeight))
    }
    if let fixedWidth = style.fixedWidth {
      constraints.append(widthAnchor.constraint(equalToConstant: fixedWidth))
    }

    // Inequality constraints
    var height: CGFloat?
    var width: CGFloat?
    if let minHeight = style.minHeight {
      constraints.append(heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight))
      height = minHeight
    }
    if let minWidth = style.minWidth {
      constraints.append(widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth))
      width = minWidth
    }
    if let maxHeight = style.maxHeight {
      constraints.append(heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight))
      height = height ?? maxHeight
    }
    if let maxWidth = style.maxWidth {
      constraints.append(widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth))
      width = width ?? maxWidth
    }

    // Inequality constraints, by themselves, result in ambiguous layouts due to the Auto Layout
    // engine not knowing what value to use in the range of possible values. To disambiguate the
    // layout, we can set a low-priority equality constraint.
    //
    // Example:
    // The height anchor is >= 50 and <= 100. Which value between 50 and 100
    // should the Auto Layout engine use? To answer this question, we need to pick a value like 50,
    // but give it a lower priority than the >= and <= inequality constraints.
    if let height = height {
      let heightConstraint = heightAnchor.constraint(equalToConstant: height)
      heightConstraint.priority = UILayoutPriority(rawValue: 1)
      constraints.append(heightConstraint)
    }
    if let width = width {
      let widthConstraint = widthAnchor.constraint(equalToConstant: width)
      widthConstraint.priority = UILayoutPriority(rawValue: 1)
      constraints.append(widthConstraint)
    }

    NSLayoutConstraint.activate(constraints)
  }

}
