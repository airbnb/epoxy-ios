// Created by Tyler Hedrick on 5/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

/// Constraints abstraction for HGroup
final class HGroupConstraints: GroupConstraints {

  // MARK: Lifecycle

  /// Private initializer that generates all necessary constraints.
  /// Please use HGroupConstraints.constraints(for:in:groupAlignment:itemSpacing:) instead
  private init(
    items: [ConstrainableContainer],
    owningConstrainable: Constrainable,
    groupAlignment: HGroup.ItemAlignment,
    itemSpacing: CGFloat)
  {
    self.groupAlignment = groupAlignment
    self.itemSpacing = itemSpacing

    switch items.count {
    case 0:
      // When the constrainable has no items, we set it's width to be 0
      constraints[owningConstrainable.dataID] = [
        owningConstrainable.widthAnchor.constraint(equalToConstant: 0),
      ]
    case 1:
      let constrainable = items[0]
      constraints[constrainable.dataID] = leadingConstraints(for: constrainable, in: owningConstrainable) +
        singleItemTrailingConstraints(for: constrainable, in: owningConstrainable)
    case 2:
      let leading = items[0]
      let trailing = items[items.count - 1]
      constraints[leading.dataID] = leadingConstraints(for: leading, in: owningConstrainable)
      constraints[trailing.dataID] = trailingConstraints(for: trailing, in: owningConstrainable)
      // glue these 2 together
      let glue = leading.trailingAnchor.constraint(
        equalTo: trailing.leadingAnchor,
        constant: -itemSpacing - leading.padding.trailing - trailing.padding.leading)
      constraints[Set([leading.dataID, trailing.dataID])] = [glue]
      leadingSpacingConstraints[leading.dataID] = glue
    default:
      let leading = items[0]
      let trailing = items[items.count - 1]
      let center = Array(items[1..<items.count - 1])
      constraints[leading.dataID] = leadingConstraints(for: leading, in: owningConstrainable)
      constraints[trailing.dataID] = trailingConstraints(for: trailing, in: owningConstrainable)
      for (idx, item) in center.enumerated() {
        switch idx {
        // this item is directly below the very top item in the group
        case 0:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            leading: leading,
            // +1 to advance to next item in array
            // +1 to account for indexing into items array using index from center array
            trailing: items[idx + 1 + 1])
        // this item is directly above the very last item in the group
        case center.count - 1:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            // -1 to advance to previous item in array
            // +1 to account for indexing into items array using index from center array
            leading: items[idx - 1 + 1],
            trailing: trailing)
        // this item is somewhere in the middle
        default:
          constraints[item.dataID] = middleConstraints(
            for: item,
            in: owningConstrainable,
            // -1 to advance to previous item in array
            // +1 to account for indexing into items array using index from center array
            leading: items[idx - 1 + 1],
            // +1 to advance to next item in array
            // +1 to account for indexing into items array using index from center array
            trailing: items[idx + 1 + 1])
        }
      }
    }
  }

  // MARK: Internal

  /// space between items
  var itemSpacing: CGFloat {
    didSet {
      leadingSpacingConstraints.forEach { $1.constant = -itemSpacing }
      trailingSpacingConstraints.forEach { $1.constant = itemSpacing }
    }
  }

  var allConstraints: [NSLayoutConstraint] {
    var result = [NSLayoutConstraint]()
    result.append(contentsOf: constraints.values.flatMap { $0 })
    result.append(contentsOf: leadingSpacingConstraints.values)
    result.append(contentsOf: trailingSpacingConstraints.values)
    return result
  }

  /// Generates a set of constraints for the HGroup layout
  /// - Parameters:
  ///   - items: a set of ConstrainableContainers to generate constraints for
  ///   - constrainable: the Constrainable that owns the items
  ///   - groupAlignment: HGroup.GroupAlignment value
  ///   - itemSpacing: space between items in the group
  /// - Returns: a populated HGroupConstraints object to install constraints
  static func constraints(
    for items: [ConstrainableContainer],
    in constrainable: Constrainable,
    groupAlignment: HGroup.ItemAlignment,
    itemSpacing: CGFloat)
    -> HGroupConstraints
  {
    HGroupConstraints(
      items: items,
      owningConstrainable: constrainable,
      groupAlignment: groupAlignment,
      itemSpacing: itemSpacing)
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

  private let groupAlignment: HGroup.ItemAlignment
  private var constraints: [AnyHashable: [NSLayoutConstraint]] = [:]
  private var leadingSpacingConstraints: [AnyHashable: NSLayoutConstraint] = [:]
  private var trailingSpacingConstraints: [AnyHashable: NSLayoutConstraint] = [:]

  /// Constraints specifically for the leading most Constrainable in the group
  /// - Parameter constrainable: constrainable to constrain
  /// - Returns: an array of un-activated constraints
  private func leadingConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    switch constrainable.verticalAlignment ?? groupAlignment {
    case .fill:
      return [
        constrainable.leadingAnchor.constraint(equalTo: owningConstrainable.leadingAnchor, constant: constrainable.padding.leading),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ]
    case .top:
      return [
        constrainable.leadingAnchor.constraint(equalTo: owningConstrainable.leadingAnchor, constant: constrainable.padding.leading),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingBottomConstraint(for: constrainable, in: owningConstrainable)
    case .center:
      return [
        constrainable.leadingAnchor.constraint(equalTo: owningConstrainable.leadingAnchor, constant: constrainable.padding.leading),
        constrainable.centerYAnchor.constraint(equalTo: owningConstrainable.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .centered(let other):
      return [
        constrainable.leadingAnchor.constraint(equalTo: owningConstrainable.leadingAnchor, constant: constrainable.padding.leading),
        constrainable.centerYAnchor.constraint(equalTo: other.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .bottom:
      return [
        constrainable.leadingAnchor.constraint(equalTo: owningConstrainable.leadingAnchor, constant: constrainable.padding.leading),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
      ] + heightAffectingTopConstraint(for: constrainable, in: owningConstrainable)
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  /// Constraints specifically for the trailing most constrainable in the group
  /// - Parameter constrainable: the constrainable to constrain
  /// - Returns: an array of un-activated constraints
  private func trailingConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    switch constrainable.verticalAlignment ?? groupAlignment {
    case .fill:
      return [
        constrainable.trailingAnchor.constraint(equalTo: owningConstrainable.trailingAnchor, constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ]
    case .top:
      return [
        constrainable.trailingAnchor.constraint(equalTo: owningConstrainable.trailingAnchor, constant: -constrainable.padding.trailing),
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingBottomConstraint(for: constrainable, in: owningConstrainable)
    case .center:
      return [
        constrainable.trailingAnchor.constraint(equalTo: owningConstrainable.trailingAnchor, constant: -constrainable.padding.trailing),
        constrainable.centerYAnchor.constraint(equalTo: owningConstrainable.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .centered(let other):
      return [
        constrainable.trailingAnchor.constraint(equalTo: owningConstrainable.trailingAnchor, constant: -constrainable.padding.trailing),
        constrainable.centerYAnchor.constraint(equalTo: other.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .bottom:
      return [
        constrainable.trailingAnchor.constraint(equalTo: owningConstrainable.trailingAnchor, constant: -constrainable.padding.trailing),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
      ] + heightAffectingTopConstraint(for: constrainable, in: owningConstrainable)
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  /// Constraints for any view that isn't at the very top or very bottom
  /// - Parameters:
  ///   - constrainable: the constrainable to constrain
  ///   - leading: the leading component for the provided constrainable
  ///   - trailing: the trailing component for the provided constrainable
  /// - Returns: an array of un-activated constraints
  private func middleConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable,
    leading: ConstrainableContainer,
    trailing: ConstrainableContainer)
    -> [NSLayoutConstraint]
  {
    let glueLeading = constrainable.leadingAnchor.constraint(
      equalTo: leading.trailingAnchor,
      constant: itemSpacing + leading.padding.trailing + constrainable.padding.leading)
    let glueTrailing = constrainable.trailingAnchor.constraint(
      equalTo: trailing.leadingAnchor,
      constant: -itemSpacing - constrainable.padding.trailing - trailing.padding.leading)
    leadingSpacingConstraints[constrainable.dataID] = glueLeading
    trailingSpacingConstraints[constrainable.dataID] = glueTrailing

    switch constrainable.verticalAlignment ?? groupAlignment {
    case .fill:
      return [
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        glueLeading,
        glueTrailing,
      ]
    case .top:
      return [
        constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        glueLeading,
        glueTrailing,
      ] + heightAffectingBottomConstraint(for: constrainable, in: owningConstrainable)
    case .center:
      return [
        constrainable.centerYAnchor.constraint(equalTo: owningConstrainable.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        glueLeading,
        glueTrailing,
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .centered(let other):
      return [
        constrainable.centerYAnchor.constraint(equalTo: other.centerYAnchor),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        constrainable.bottomAnchor.constraint(lessThanOrEqualTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        glueLeading,
        glueTrailing,
      ] + heightAffectingTopAndBottomConstraints(for: constrainable, in: owningConstrainable)
    case .bottom:
      return [
        constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom),
        constrainable.topAnchor.constraint(greaterThanOrEqualTo: owningConstrainable.topAnchor, constant: constrainable.padding.top),
        glueLeading,
        glueTrailing,
      ] + heightAffectingTopConstraint(for: constrainable, in: owningConstrainable)
    case .custom(_, let block):
      return block(owningConstrainable, constrainable)
    }
  }

  /// Generates very low priority constraints to ensure the group has a non-ambiguous height
  /// and that the elements do not go outside of the group's bounds
  private func heightAffectingTopConstraint(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    let constraint = constrainable.topAnchor.constraint(equalTo: owningConstrainable.topAnchor, constant: constrainable.padding.top)
    // set this constraint's priority just above that of the fittingSizeLevel which will
    // ensure this constraint has just enough priority to ensure it affects the size of the component
    // while being below the priority of layout constraints. Any layout constraint with a priority below
    // this value is a programmer error.
    constraint.priority = .fittingSizeLevel + 1
    return [constraint]
  }

  /// Generates very low priority constraints to ensure the group has a non-ambiguous height
  /// and that the elements do not go outside of the group's bounds
  private func heightAffectingBottomConstraint(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    let constraint = constrainable.bottomAnchor.constraint(equalTo: owningConstrainable.bottomAnchor, constant: -constrainable.padding.bottom)
    // set this constraint's priority just above that of the fittingSizeLevel which will
    // ensure this constraint has just enough priority to ensure it affects the size of the component
    // while being below the priority of layout constraints. Any layout constraint with a priority below
    // this value is a programmer error.
    constraint.priority = .fittingSizeLevel + 1
    return [constraint]
  }

  /// Generates very low priority constraints to ensure the group has a non-ambiguous height
  /// and that the elements do not go outside of the group's bounds
  private func heightAffectingTopAndBottomConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    heightAffectingTopConstraint(for: constrainable, in: owningConstrainable) +
      heightAffectingBottomConstraint(for: constrainable, in: owningConstrainable)
  }

  /// Constraints used for when the HGroup has a single item and needs
  /// to be constrained to the trailing edge
  private func singleItemTrailingConstraints(
    for constrainable: ConstrainableContainer,
    in owningConstrainable: Constrainable)
    -> [NSLayoutConstraint]
  {
    switch constrainable.verticalAlignment ?? groupAlignment {
    case .fill, .top, .bottom, .center, .centered:
      return [
        constrainable.trailingAnchor.constraint(
          equalTo: owningConstrainable.trailingAnchor,
          constant: -constrainable.padding.trailing),
      ]
    case .custom:
      return []
    }
  }

}
