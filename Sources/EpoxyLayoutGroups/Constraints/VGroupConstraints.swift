// Created by Tyler Hedrick on 5/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

/// Constraints abstraction for VGroup
final class VGroupConstraints: GroupConstraints {

  // MARK: Lifecycle

  private init(
    items: [ConstrainableContainer],
    owningConstrainable: Constrainable,
    groupAlignment: VGroup.ItemAlignment,
    itemSpacing: CGFloat,
    useAccessibilityAlignment: Bool)
  {
    self.itemSpacing = itemSpacing
    self.groupAlignment = groupAlignment
    self.useAccessibilityAlignment = useAccessibilityAlignment

    switch items.count {
    case 0:
      // When the constrainable has no items, we set it's height to be 0
      constraints[owningConstrainable.dataID] = [
        owningConstrainable.heightAnchor.constraint(equalToConstant: 0),
      ]
    case 1:
      let constrainable = items[0]
      constraints[constrainable.dataID] = topConstraints(for: constrainable, in: owningConstrainable) +
        singleItemBottomConstraints(for: constrainable, in: owningConstrainable)
    case 2:
      let top = items[0]
      let bottom = items[items.count - 1]
      constraints[top.dataID] = topConstraints(for: top, in: owningConstrainable)
      constraints[bottom.dataID] = bottomConstraints(for: bottom, in: owningConstrainable)
      // glue these 2 together
      let glue = top.bottomAnchor.constraint(
        equalTo: bottom.topAnchor,
        constant: -itemSpacing - top.padding.bottom - bottom.padding.top)
      constraints[Set([top.dataID, bottom.dataID])] = [glue]
      bottomSpacingConstraints[top.dataID] = glue
    default:
      let top = items[0]
      let bottom = items[items.count - 1]
      let center = Array(items[1..<items.count - 1])
      constraints[top.dataID] = topConstraints(for: top, in: owningConstrainable)
      constraints[bottom.dataID] = bottomConstraints(for: bottom, in: owningConstrainable)
      for (idx, item) in center.enumerated() {
        switch idx {
        // this item is directly below the very top item in the group
        case 0:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            top: top,
            // +1 to advance to next item in array
            // +1 to account for indexing into items array using index from center array
            bottom: items[idx + 1 + 1])
        // this item is directly above the very last item in the group
        case center.count - 1:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            // -1 to advance to previous item in array
            // +1 to account for indexing into items array using index from center array
            top: items[idx - 1 + 1],
            bottom: bottom)
        // this item is somewhere in the middle
        default:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            // -1 to advance to previous item in array
            // +1 to account for indexing into items array using index from center array
            top: items[idx - 1 + 1],
            // +1 to advance to next item in array
            // +1 to account for indexing into items array using index from center array
            bottom: items[idx + 1 + 1])
        }
      }
    }
  }

  // MARK: Internal

  /// space between items
  var itemSpacing: CGFloat {
    didSet {
      topSpacingConstraints.forEach { $1.constant = itemSpacing }
      bottomSpacingConstraints.forEach { $1.constant = -itemSpacing }
    }
  }

  var allConstraints: [NSLayoutConstraint] {
    constraints.values.flatMap { $0 } + topSpacingConstraints.values + bottomSpacingConstraints.values
  }

  /// Generates a set of constraints for the VGroup layout
  /// - Parameters:
  ///   - items: a set of ConstrainableContainers to generate constraints for
  ///   - constrainable: the Constrainable that owns the items
  ///   - itemSpacing: space between items in the group
  ///   - groupAlignment: the alignment used for the group
  ///   - useAccessibilityAlignment: whether or not the `accessibilityAlignment`
  ///   property of the ConstrainableContainers should be used or the regular
  ///   `alignment` property
  /// - Returns: a populated HGroupConstraints object to install constraints
  static func constraints(
    for items: [ConstrainableContainer],
    in constrainable: Constrainable,
    groupAlignment: VGroup.ItemAlignment,
    itemSpacing: CGFloat,
    useAccessibilityAlignment: Bool = false)
    -> VGroupConstraints
  {
    VGroupConstraints(
      items: items,
      owningConstrainable: constrainable,
      groupAlignment: groupAlignment,
      itemSpacing: itemSpacing,
      useAccessibilityAlignment: useAccessibilityAlignment)
  }

  /// install the constraints
  func install() {
    NSLayoutConstraint.activate(allConstraints)
  }

  /// uninstall the constraints
  func uninstall() {
    NSLayoutConstraint.deactivate(allConstraints)
  }

  // MARK: Private

  private let groupAlignment: VGroup.ItemAlignment

  private let useAccessibilityAlignment: Bool
  private var constraints: [AnyHashable: [NSLayoutConstraint]] = [:]
  private var topSpacingConstraints: [AnyHashable: NSLayoutConstraint] = [:]
  private var bottomSpacingConstraints: [AnyHashable: NSLayoutConstraint] = [:]

  /// Constraints specifically for the top most Constrainable in the group
  /// - Parameter constrainable: constrainable to constrain
  /// - Returns: an array of un-activated constraints
  private func topConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    var alignment = constrainable.horizontalAlignment ?? groupAlignment
    if useAccessibilityAlignment {
      alignment = constrainable.accessibilityAlignment ?? alignment
    }
    switch alignment {
    case .fill:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
      ]
    case .leading:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
      ]
    case .center:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.centerXAnchor.constraint(equalTo: owningConstrainable.centerXAnchor),
      ]
    case .centered(let other):
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.centerXAnchor.constraint(equalTo: other.centerXAnchor),
      ]
    case .trailing:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
      ]
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  /// Constraints specifically for the bottom-most constrainable in the group
  /// - Parameter constrainable: the constrainable to constrain
  /// - Returns: an array of un-activated constraints
  private func bottomConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    var alignment = constrainable.horizontalAlignment ?? groupAlignment
    if useAccessibilityAlignment {
      alignment = constrainable.accessibilityAlignment ?? alignment
    }
    switch alignment {
    case .fill:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ]
    case .leading:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ]
    case .center:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        constrainable.centerXAnchor.constraint(equalTo: owningConstrainable.centerXAnchor),
      ]
    case .centered(let other):
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        constrainable.centerXAnchor.constraint(equalTo: other.centerXAnchor),
      ]
    case .trailing:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ]
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  /// Constraints for any view that isn't at the very top or very bottom
  /// - Parameters:
  ///   - constrainable: the constrainable to constrain
  ///   - top: the top component for the provided constrainable
  ///   - bottom: the bottom component for the provided constrainable
  /// - Returns: an array of un-activated constraints
  private func middleConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable,
    top: ConstrainableContainer,
    bottom: ConstrainableContainer)
    -> [NSLayoutConstraint]
  {
    let glueTop = constrainable.topAnchor.constraint(
      equalTo: top.bottomAnchor,
      constant: itemSpacing + top.padding.bottom + constrainable.padding.top)
    let glueBottom = constrainable.bottomAnchor.constraint(
      equalTo: bottom.topAnchor,
      constant: -itemSpacing - constrainable.padding.bottom - bottom.padding.top)
    topSpacingConstraints[constrainable.dataID] = glueTop
    bottomSpacingConstraints[constrainable.dataID] = glueBottom

    var alignment = constrainable.horizontalAlignment ?? groupAlignment
    if useAccessibilityAlignment {
      alignment = constrainable.accessibilityAlignment ?? alignment
    }
    switch alignment {
    case .fill:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        glueTop,
        glueBottom,
      ]
    case .leading:
      return [
        constrainable.leadingAnchor.constraint(
          equalTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        glueTop,
        glueBottom,
      ]
    case .center:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        glueTop,
        glueBottom,
        constrainable.centerXAnchor.constraint(equalTo: owningConstrainable.centerXAnchor),
      ]
    case .centered(let other):
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          lessThanOrEqualTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        glueTop,
        glueBottom,
        constrainable.centerXAnchor.constraint(equalTo: other.centerXAnchor),
      ]
    case .trailing:
      return [
        constrainable.leadingAnchor.constraint(
          greaterThanOrEqualTo: owningConstrainable.leadingAnchor,
          constant: constrainable.padding.leading),
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
        glueTop,
        glueBottom,
      ]
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  private func singleItemBottomConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    var alignment = constrainable.horizontalAlignment ?? groupAlignment
    if useAccessibilityAlignment {
      alignment = constrainable.accessibilityAlignment ?? alignment
    }
    switch alignment {
    case .fill, .leading, .trailing, .center, .centered:
      return [
        constrainable.bottomAnchor.constraint(
          equalTo: owningConstrainable.bottomAnchor,
          constant: -constrainable.padding.bottom),
      ]
    case .custom:
      return []
    }
  }

}
