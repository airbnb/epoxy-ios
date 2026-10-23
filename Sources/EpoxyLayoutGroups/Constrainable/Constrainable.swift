// Created by Tyler Hedrick on 1/21/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - Constrainable

/// Defines something that can be constrained with AutoLayout
///
/// Layout operations require the main actor. Identity and equality remain nonisolated for diffing.
public protocol Constrainable {
  @MainActor var leadingAnchor: NSLayoutXAxisAnchor { get }
  @MainActor var trailingAnchor: NSLayoutXAxisAnchor { get }
  @MainActor var leftAnchor: NSLayoutXAxisAnchor { get }
  @MainActor var rightAnchor: NSLayoutXAxisAnchor { get }
  @MainActor var topAnchor: NSLayoutYAxisAnchor { get }
  @MainActor var bottomAnchor: NSLayoutYAxisAnchor { get }
  @MainActor var widthAnchor: NSLayoutDimension { get }
  @MainActor var heightAnchor: NSLayoutDimension { get }
  @MainActor var centerXAnchor: NSLayoutXAxisAnchor { get }
  @MainActor var centerYAnchor: NSLayoutYAxisAnchor { get }
  @MainActor var firstBaselineAnchor: NSLayoutYAxisAnchor { get }
  @MainActor var lastBaselineAnchor: NSLayoutYAxisAnchor { get }
  /// unique identifier for this constrainable
  nonisolated var dataID: AnyHashable { get }
  /// View that owns this constrainable
  @MainActor var owningView: UIView? { get }
  /// The frame of the Constrainable in its owningView's coordinate system.
  /// Valid by the time the owningView receives `layoutSubviews()`.
  @MainActor var layoutFrame: CGRect { get }

  /// install the Constrainable into the provided view
  @MainActor
  func install(in view: UIView)
  /// uninstalls the Constrainable
  @MainActor
  func uninstall()
  /// equality function
  nonisolated func isEqual(to constrainable: Constrainable) -> Bool
}

extension Constrainable where Self: NSObject {
  public nonisolated var dataID: AnyHashable { ObjectIdentifier(self) }
}

// MARK: Diffable

extension Constrainable {
  public var diffIdentifier: AnyHashable { dataID }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let other = otherDiffableItem as? Constrainable else {
      return false
    }
    return isEqual(to: other)
  }
}

// MARK: - UIView + Constrainable

extension UIView {
  public var owningView: UIView? {
    superview
  }

  public var layoutFrame: CGRect {
    frame
  }

  public func install(in view: UIView) {
    view.addSubview(self)
  }

  public func uninstall() {
    removeFromSuperview()
  }

  public nonisolated func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? UIView else { return false }
    return other == self
  }
}

@MainActor
extension Constrainable {
  public func constrainToMargins(insets: NSDirectionalEdgeInsets = .zero) {
    guard let owningView = owningView else {
      EpoxyLogger.shared.assertionFailure("Did you forget to install the LayoutGuide?")
      return
    }

    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: owningView.layoutMarginsGuide.leadingAnchor, constant: insets.leading),
      trailingAnchor.constraint(equalTo: owningView.layoutMarginsGuide.trailingAnchor, constant: -insets.trailing),
      topAnchor.constraint(equalTo: owningView.layoutMarginsGuide.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: owningView.layoutMarginsGuide.bottomAnchor, constant: -insets.bottom),
    ])
  }

  /// Constrains the edges of this Constrainable to the layoutMarginsGuide of its `owningView`.
  /// The bottom constraint's priority is set to `defaultHigh` to avoid layout errors when used
  /// in Epoxy cells
  public func constrainToMarginsWithHighPriorityBottom() {
    guard let owningView = owningView else {
      EpoxyLogger.shared.assertionFailure("Did you forget to install the LayoutGuide?")
      return
    }

    let bottom = bottomAnchor.constraint(equalTo: owningView.layoutMarginsGuide.bottomAnchor)
    bottom.priority = .defaultHigh
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: owningView.layoutMarginsGuide.leadingAnchor),
      trailingAnchor.constraint(equalTo: owningView.layoutMarginsGuide.trailingAnchor),
      topAnchor.constraint(equalTo: owningView.layoutMarginsGuide.topAnchor),
      bottom,
    ])
  }

  public func constrainToSuperview() {
    guard let owningView = owningView else {
      EpoxyLogger.shared.assertionFailure("Did you forget to install the LayoutGuide?")
      return
    }

    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: owningView.leadingAnchor),
      trailingAnchor.constraint(equalTo: owningView.trailingAnchor),
      topAnchor.constraint(equalTo: owningView.topAnchor),
      bottomAnchor.constraint(equalTo: owningView.bottomAnchor),
    ])
  }
}

// Keep identity and equality available outside the main actor when conformance isolation is inferred.
#if compiler(>=6.2)
extension UIView: nonisolated Constrainable { }
#else
extension UIView: Constrainable { }
#endif
