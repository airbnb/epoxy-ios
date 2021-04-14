// Created by Tyler Hedrick on 5/18/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - Group

/// Defines a group of Constrainables
public protocol Group: Constrainable {
  /// The set of items this Group is responsible for laying out
  var items: [AnyGroupItem] { get }

  /// Replace the current items with a new set of items.
  /// This does intelligent diffing to only replace items needed
  /// and then recreates all of the constraints.
  /// This method does nothing if the array of new items is identical
  /// to the existing set of items
  func setItems(_ newItems: [GroupItemModeling])

  /// Result builder syntax equivalent of `setItems`
  /// This allows you to do:
  /// ```
  /// group.setItems {
  ///   groupItem1
  ///   groupItem2
  /// }
  /// ```
  func setItems(@GroupModelBuilder _ buildItems: () -> [GroupItemModeling])
}

// MARK: - InternalGroup

/// Protocol for shared logic between groups
/// For internal use only
protocol InternalGroup: AnyObject, Group {
  /// a settable version of the ivar of items found in Groups
  var items: [AnyGroupItem] { get set }
  /// contains the built constrainable containers from items
  var constrainableContainers: [ConstrainableContainer] { get set }
  /// The current set of constraints applied to the Group
  var constraints: GroupConstraints? { get set }

  /// Uninstalls and re-installs all constraints
  func installConstraintsIfNeeded()
  /// returns a set of constraints for the current state
  func generateConstraints() -> GroupConstraints?
}

extension Constrainable where Self: InternalGroup {

  /// Shared implementation of `setItems(_ newItems:)`
  func _setItems(_ newItems: [GroupItemModeling]) {
    assert(validateItems(newItems))

    let oldItems = items
    let newItemsErased = newItems.eraseToAnyGroupItems()
    let changeset = newItemsErased.makeChangeset(from: oldItems)

    guard !changeset.isEmpty else {
      // we still update behaviors even if the items don't have changes
      // since behaviors are non-equatable and can change without our knowledge
      resetBehaviors()
      return
    }

    items = newItemsErased
    constraints?.uninstall()

    var newConstrainableContainers = constrainableContainers
    let oldConstrainableContainers = constrainableContainers

    for (from, to) in changeset.updates {
      let toItem = newItemsErased[to]
      toItem.update(newConstrainableContainers[from].wrapped)
    }

    for index in changeset.deletes.reversed() {
      let constrainable = newConstrainableContainers.remove(at: index)
      constrainable.uninstall()
    }

    for index in changeset.inserts {
      let item = newItemsErased[index]
      let constrainable = item.makeConstrainable()
      let container = ConstrainableContainer(constrainable)
      item.update(constrainable)
      newConstrainableContainers.insert(container, at: index)
      if let owningView = owningView {
        container.install(in: owningView)
      }
    }

    for (from, to) in changeset.moves {
      newConstrainableContainers[to] = oldConstrainableContainers[from]
    }

    constrainableContainers = newConstrainableContainers
    resetBehaviors()

    assert(validateConstrainables(constrainableContainers))

    if owningView != nil {
      let newConstraints = generateConstraints()
      newConstraints?.install()
      constraints = newConstraints
    }
  }

  func resetBehaviors() {
    guard constrainableContainers.count == items.count else {
      EpoxyLogger.shared.assertionFailure("Containers and items are mismatched, this should never happen and is a failure of the system. Please file a bug report.")
      return
    }
    zip(constrainableContainers, items).forEach { container, item in
      item.setBehaviors(on: container)
    }
  }

  func installConstraintsIfNeeded() {
    guard owningView != nil else { return }
    let new = generateConstraints()
    guard constraints?.allConstraints != new?.allConstraints else {
      return
    }
    constraints?.uninstall()
    constraints = new
    constraints?.install()
  }

  /// Ensures all Constrainable items are valid for use in groups
  /// and will work properly with auto layout constraints
  func validateConstrainables(_ constrainableContainers: [Constrainable?]) -> Bool {
    var isValid = true
    for item in constrainableContainers {
      guard var constrainable = item else { continue }
      if let container = constrainable as? ConstrainableContainer {
        constrainable = container.wrapped
      }
      if let view = constrainable as? UIView {
        isValid = isValid && view.translatesAutoresizingMaskIntoConstraints == false
        assert(isValid, "All UIViews must have `translatesAutoresizingMaskIntoConstraints` set to false")
      }
    }
    return isValid
  }

  func validateItems(_ items: [GroupItemModeling]) -> Bool {
    var dataIDs = Set<AnyHashable>()
    for item in items {
      let dataID = item.eraseToAnyGroupItem().dataID
      if dataIDs.contains(dataID) {
        EpoxyLogger.shared.assertionFailure("All items must have unique dataIDs")
        return false
      }
      dataIDs.insert(dataID)
    }
    return true
  }

}

extension InternalGroup where Self: UILayoutGuide {
  /// shared implementation of install(in view:)
  func _install(in view: UIView) {
    view.addLayoutGuide(self)
    constrainableContainers.forEach { $0.install(in: view) }
    installConstraintsIfNeeded()
  }

  /// shared implementation of uninstall()
  func _uninstall() {
    constrainableContainers.forEach { $0.uninstall() }
    owningView?.removeLayoutGuide(self)
  }
}
