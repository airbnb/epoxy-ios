//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - CollectionViewDataSource

/// The internal `UICollectionViewDataSource` of `CollectionView`.
final class CollectionViewDataSource: NSObject {

  // MARK: Internal

  /// The result of applying new data to this data source.
  struct ApplyDataResult {
    /// The changes from the new data to the old data
    var changeset: CollectionViewChangeset

    /// The previous data, used to identify disappearing items from the old index paths.
    var oldData: CollectionViewData
  }

  weak var reorderingDelegate: CollectionViewDataSourceReorderingDelegate?

  private(set) var data: CollectionViewData?

  weak var collectionView: CollectionView? {
    didSet {
      guard collectionView !== oldValue else { return }
      reregisterViewDifferentiators()
    }
  }

  /// All supplementary view element kinds that have been registered with this data source.
  var supplementaryViewElementKinds: Set<String> {
    .init(registeredSupplementaryViewDifferentiators.keys)
  }

  /// Registers reuse IDs for the items in the given sections with this data source's associated
  /// `CollectionView`.
  func registerSections(_ sections: [SectionModel]) {
    registerViewDifferentiators(with: sections)
    registerSupplementaryViewDifferentiators(with: sections)
  }

  /// Applies the given new data to this data source, returning old data and the minimal changes
  /// necessary to get to the provided new data.
  func applyData(_ newData: CollectionViewData) -> ApplyDataResult {
    let oldData = data ?? .make(sections: [])
    data = newData
    return .init(changeset: newData.makeChangeset(from: oldData), oldData: oldData)
  }

  /// Refreshes the internalData but does not trigger a UI update.
  /// Should only be used in special situations which require a specific order of operations
  /// to work properly, in most cases you should use `setSections` instead.
  ///
  /// Here's an example of implementing `tableView(tableView: performDropWith:)`
  /// when you use a UITableViewDropDelegate to reorder rows:
  ///
  /// 1) Move the row manually:
  ///
  ///   tableView.moveRow(
  ///     at: sourceIndexPath,
  ///     to: destinationIndexPath)
  ///
  /// 2) Move the row in your data source, then call refreshDataWithoutUpdating()
  ///    (in this example, stagedSortingItems is the data source):
  ///
  ///   let updatedSections = <Modified sections array with item moved to new location>
  ///   myDataSource.modifySectionsWithoutUpdating(updatedSections)
  ///
  /// 3) Animate the row into place:
  ///
  ///   coordinator.drop(firstItem.dragItem, toRowAt: destinationIndexPath)
  ///
  func modifySectionsWithoutUpdating(_ sections: [SectionModel]) {
    data = .make(sections: sections)
  }

  // MARK: Private

  private let reuseIDStore = ReuseIDStore()

  /// The set of cell ViewDifferentiators that have been registered on the collection view.
  private var registeredCellViewDifferentiators = Set<ViewDifferentiator>()
  /// The set of supplementary view ViewDifferentiators that have been registered on the collection
  /// view, keyed by element kind.
  private var registeredSupplementaryViewDifferentiators = [String: Set<ViewDifferentiator>]()

  private func reregisterViewDifferentiators() {
    registerNewViewDifferentiators(registeredCellViewDifferentiators)
    for (elementKind, viewDifferentiators) in registeredSupplementaryViewDifferentiators {
      registerNewSupplementaryViewDifferentiator(viewDifferentiators, forKind: elementKind)
    }
  }

  private func registerViewDifferentiators(with sections: [SectionModel]?) {
    let newViewDifferentiators = sections?.getItemViewDifferentiators() ?? []
    registerNewViewDifferentiators(
      newViewDifferentiators.subtracting(registeredCellViewDifferentiators))
    registeredCellViewDifferentiators =
      registeredCellViewDifferentiators.union(newViewDifferentiators)
  }

  private func registerSupplementaryViewDifferentiators(with sections: [SectionModel]?) {
    let newViewDifferentiators = sections?.getSupplementaryViewDifferentiators() ?? [:]
    for (elementKind, newElementViewDifferentiators) in newViewDifferentiators {
      let existingViewDifferentiators = registeredSupplementaryViewDifferentiators[elementKind]
        ?? []
      registerNewSupplementaryViewDifferentiator(
        newElementViewDifferentiators.subtracting(existingViewDifferentiators),
        forKind: elementKind)
      registeredSupplementaryViewDifferentiators[elementKind] = existingViewDifferentiators
        .union(newElementViewDifferentiators)

    }
  }

  private func registerNewViewDifferentiators(_ newViewDifferentiators: Set<ViewDifferentiator>) {
    guard let collectionView = collectionView else {
      EpoxyLogger.shared.assertionFailure(
        "Trying to register reuse IDs before the CollectionView was set.")
      return
    }
    for viewDifferentiator in newViewDifferentiators {
      let reuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator)
      collectionView.register(cellReuseID: reuseID)
    }
  }

  private func registerNewSupplementaryViewDifferentiator(
    _ newViewDifferentiators: Set<ViewDifferentiator>,
    forKind elementKind: String)
  {
    guard let collectionView = collectionView else {
      EpoxyLogger.shared.assertionFailure(
        "Trying to register reuse IDs before the CollectionView was set.")
      return
    }
    for viewDifferentiator in newViewDifferentiators {
      let reuseID = reuseIDStore.reuseID(byRegistering: viewDifferentiator)
      collectionView.register(
        supplementaryViewReuseID: reuseID,
        forKind: elementKind)
    }
  }

}

// MARK: UICollectionViewDataSource

extension CollectionViewDataSource: UICollectionViewDataSource {

  func numberOfSections(in _: UICollectionView) -> Int {
    guard let data = data else { return 0 }

    return data.sections.count
  }

  func collectionView(
    _: UICollectionView,
    numberOfItemsInSection section: Int)
    -> Int
  {
    guard let data = data else { return 0 }

    return data.sections[section].items.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    guard
      let item = data?.item(at: indexPath),
      let reuseID = reuseIDStore.registeredReuseID(for: item.viewDifferentiator)
    else {
      // The `item(…)` or `registeredReuseID(…)` methods will assert in this scenario.
      return UICollectionViewCell()
    }

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)

    if let cell = cell as? CollectionViewCell {
      self.collectionView?.configure(cell: cell, with: item, animated: false)
    } else {
      EpoxyLogger.shared.assertionFailure(
        "Only CollectionViewCell and subclasses are allowed in a CollectionView.")
    }
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath)
    -> UICollectionReusableView
  {
    guard
      let item = data?.supplementaryItem(ofKind: kind, at: indexPath),
      let reuseID = reuseIDStore.registeredReuseID(for: item.viewDifferentiator)
    else {
      // The `supplementaryItem(…)` or `registeredReuseID(…)` methods will assert in this scenario.
      return UICollectionReusableView()
    }

    let supplementaryView = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: reuseID,
      for: indexPath)

    if let supplementaryView = supplementaryView as? CollectionViewReusableView {
      self.collectionView?.configure(
        supplementaryView: supplementaryView,
        with: item,
        animated: false)
    } else {
      EpoxyLogger.shared.assertionFailure(
        "Only CollectionViewReusableView and subclasses are allowed in a CollectionView.")
    }

    return supplementaryView
  }

  func collectionView(
    _: UICollectionView,
    canMoveItemAt indexPath: IndexPath)
    -> Bool
  {
    guard let item = data?.item(at: indexPath) else { return false }
    return item.isMovable
  }

  func collectionView(
    _: UICollectionView,
    moveItemAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath)
  {
    guard
      let data = data,
      let sourceItem = data.item(at: sourceIndexPath),
      let sourceSection = data.section(at: sourceIndexPath.section),
      let destinationSection = data.section(at: destinationIndexPath.section)
    else {
      return
    }

    let beforeIndexPath = IndexPath(
      item: destinationIndexPath.item,
      section: destinationIndexPath.section)

    if
      data.sections[beforeIndexPath.section].items.count >= beforeIndexPath.item + 1,
      let destinationItem = data.item(at: beforeIndexPath)
    {
      reorderingDelegate?
        .dataSource(
          self,
          moveItem: sourceItem,
          inSection: sourceSection,
          toDestinationItem: destinationItem,
          inSection: destinationSection)
    }
  }

}
