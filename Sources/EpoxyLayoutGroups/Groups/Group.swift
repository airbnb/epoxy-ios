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
  /// - Parameters:
  ///   - newItems: the new set of items to set on the group
  ///   - animated: whether or not this change should be animated
  func setItems(_ newItems: [GroupItemModeling], animated: Bool)

  /// Result builder syntax equivalent of `setItems`
  ///
  /// This allows you to do:
  /// ```
  /// group.setItems {
  ///   groupItem1
  ///   groupItem2
  /// }
  /// ```
  /// - Parameters:
  ///   - buildItems: a builder that builds the new set of items to be set
  ///   - animated: whether or not this change should be animated
  func setItems(@GroupModelBuilder _ buildItems: () -> [GroupItemModeling], animated: Bool)

  /// Returns the rendered `Constrainable` for the given `dataID` or `nil` if it does not exist.
  /// This will return the underlying `Constrainable` and not the `ConstrainableContainer`.
  /// Note that the `Constrainable`'s `dataID` will not necessarily match the provided `dataID`
  /// as `GroupItem` `dataID`'s are not the same as their rendered `Constrainable`'s `dataIDs`.
  /// This is because we cannot control the rendered `Constrainable` `dataID` as they are often
  /// `UIView`s where we use the `ObjectIdentifier` value to uniquely identify them.
  func constrainable(with dataID: AnyHashable) -> Constrainable?

  /// Returns the `GroupItemModeling` for the given `dataID` or `nil` if it does not exist.
  func groupItem(with dataID: AnyHashable) -> AnyGroupItem?
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
  /// Whether or not this group is hidden
  var isHidden: Bool { get set }
  /// a mapping of dataIDs to their associated index in the `items`
  /// and `constrainableContainers` array
  var dataIDIndexMap: [AnyHashable: Int] { get set }

  /// Uninstalls and re-installs all constraints
  func installConstraintsIfNeeded()
  /// returns a set of constraints for the current state
  func generateConstraints() -> GroupConstraints?
}

extension Constrainable where Self: InternalGroup {

  func _constrainable(with dataID: AnyHashable) -> Constrainable? {
    guard let index = dataIDIndexMap[dataID] else {
      return nil
    }
    guard index >= 0 && index < constrainableContainers.count else {
      EpoxyLogger.shared.assertionFailure("Attempt to access a constrainable out of bounds. Make sure you've called this method only after updating the group, the view has rendered, and layoutSubviews has been called.")
      return nil
    }
    return constrainableContainers[index].wrapped
  }

  func _groupItem(with dataID: AnyHashable) -> AnyGroupItem? {
    guard let index = dataIDIndexMap[dataID] else {
      return nil
    }
    guard index >= 0 && index < items.count else {
      EpoxyLogger.shared.assertionFailure("Attempt to access a group item out of bounds. Make sure you've called this method only after setting the items on the group.")
      return nil
    }
    return items[index]
  }

  /// Shared implementation of `setItems(_ newItems:)`
  func _setItems(_ newItems: [GroupItemModeling], animated: Bool) {
    assert(validateItems(newItems))

    let oldItems = items
    let newItemsErased = newItems.eraseToAnyGroupItems()
    items = newItemsErased

    let changeset = newItemsErased.makeChangeset(from: oldItems)
    guard !changeset.isEmpty else {
      // we still update behaviors even if the items don't have changes
      // since behaviors are non-equatable and can change without our knowledge
      resetBehaviors()
      return
    }

    // the final set of containers after updates
    var newConstrainableContainers = constrainableContainers
    // an intermediate set of containers that is used to generate
    // constraints for an intermediate layout used for smooth animations
    var intermediateContainers = constrainableContainers
    // the original set of containers we are updating from
    let oldConstrainableContainers = constrainableContainers

    var added = [ConstrainableContainer]()
    var toRemove = [ConstrainableContainer]()

    for (from, to) in changeset.updates {
      let toItem = newItemsErased[to]
      toItem.update(newConstrainableContainers[from].wrapped, animated: animated)
    }

    for index in changeset.deletes.reversed() {
      let constrainable = newConstrainableContainers.remove(at: index)
      if animated {
        toRemove.append(constrainable)
      } else {
        constrainable.uninstall()
      }
    }

    for index in changeset.inserts {
      let item = newItemsErased[index]
      let constrainable = item.makeConstrainable()
      let container = ConstrainableContainer(constrainable)
      item.update(constrainable, animated: animated)
      newConstrainableContainers.insert(container, at: index)
      if let owningView = owningView {
        container.install(in: owningView)
      }
      intermediateContainers.insert(container, at: index)
      added.append(container)
    }

    for (from, to) in changeset.moves {
      newConstrainableContainers[to] = oldConstrainableContainers[from]
    }

    // prepare for animations by setting the alpha value of our new items
    // to 0, and creating an intermediate layout which includes all items
    // that have been inserted and removed. This allows us to have a smooth
    // transition between layouts by forcing this view to layout incoming subviews
    if animated && owningView != nil {
      for container in added {
        container.setHiddenForAnimatedUpdates(true)
      }
      constraints?.uninstall()
      constrainableContainers = intermediateContainers
      constraints = generateConstraints()
      constraints?.install()
      // force a layout with our hidden elements to ensure they have a proper frame
      owningView?.layoutIfNeeded()
    }

    constrainableContainers = newConstrainableContainers
    resetBehaviors()

    assert(validateConstrainables(constrainableContainers))

    if let owningView = owningView {
      let oldConstraints = constraints
      let newConstraints = generateConstraints()
      constraints = newConstraints

      if animated {
        UIView.animate(
          withDuration: 0.5,
          delay: 0,
          usingSpringWithDamping: 1.0,
          initialSpringVelocity: 0,
          options: [.beginFromCurrentState, .allowUserInteraction],
          animations: {
            // Remove the old constraints but keep all of the items we are going to
            // remove in place for smooth animations
            oldConstraints?.uninstall()
            self.constrainAllItemsInPlace(toRemove)

            // hide all of the items we are going to remove which fades them out
            // during the animation
            for container in toRemove {
              container.setHiddenForAnimatedUpdates(true)
            }
            // unhide all of the new items to fade them in
            for container in added {
              container.setHiddenForAnimatedUpdates(false)
            }
            // install the new constraints in the animation block which will
            // handle moving elements as appropriate
            newConstraints?.install()
            owningView.layoutIfNeeded()
          },

          completion: { _ in
            self.finalizeAnimationsWithRemovedItems(toRemove)
          })
      } else {
        oldConstraints?.uninstall()
        newConstraints?.install()
      }
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

  /// Keep all of the given items in the current spot they are in
  func constrainAllItemsInPlace(_ items: [ConstrainableContainer]) {
    for container in items {
      // recursively call this on items in subgroups
      if let group = container.wrapped as? InternalGroup {
        constrainAllItemsInPlace(group.constrainableContainers)
      }
      // by setting translatesAutoresizingMaskIntoConstraints = true
      // we are telling the system that we want this view to rely on its
      // current frame. Elsewhere, we remove all constraints from this view
      // which effectively keeps it in place.
      if let view = container.wrapped as? UIView {
        view.translatesAutoresizingMaskIntoConstraints = true
      }
    }
  }

  func finalizeAnimationsWithRemovedItems(_ items: [ConstrainableContainer]) {
    // finally, remove all of the deleted items
    for container in items {
      container.uninstall()
      // reset this value once it has been removed
      (container.wrapped as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
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

  func resetIndexMap() {
    dataIDIndexMap.removeAll()
    items.enumerated().forEach { (idx, item) in
      dataIDIndexMap[item.dataID] = idx
    }
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
