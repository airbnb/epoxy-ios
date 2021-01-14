//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - CollectionViewDataSourceReorderingDelegate

protocol CollectionViewDataSourceReorderingDelegate: AnyObject {
  func dataSource(
    _ dataSource: CollectionViewEpoxyDataSource,
    moveItemWithDataID dataID: AnyHashable,
    inSectionWithDataID fromSectionDataID: AnyHashable,
    toSectionWithDataID toSectionDataID: AnyHashable,
    withDestinationDataId destinationDataId: AnyHashable)
}

// MARK: - CollectionViewEpoxyDataSource

final class CollectionViewEpoxyDataSource: NSObject {

  // MARK: Internal

  weak var reorderingDelegate: CollectionViewDataSourceReorderingDelegate?

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

  private(set) var data: InternalCollectionViewEpoxyData?

  /// Registers reuse IDs for the items in the given sections with this data source's associated
  /// `CollectionView`.
  func registerSections(_ sections: [SectionModel]) {
    registerViewDifferentiators(with: sections)
    registerSupplementaryViewDifferentiators(with: sections)
  }

  /// The result of applying new data to this data source.
  struct ApplyDataResult {
    /// The changes from the new data to the old data
    var changeset: CollectionViewChangeset

    /// The previous data, used to identify disappearing items from the old index paths.
    var oldData: InternalCollectionViewEpoxyData
  }

  /// Applies the given new data to this data source, returning old data and the minimal changes
  /// necessary to get to the provided new data.
  func applyData(_ newData: InternalCollectionViewEpoxyData) -> ApplyDataResult? {
    let oldData = self.data
    self.data = newData
    if GlobalEpoxyConfig.shared.usesBatchUpdatesForAllReloads {
      let oldData = oldData ?? .make(sections: [])
      return .init(changeset: newData.makeChangeset(from: oldData), oldData: oldData)
    } else {
      guard let oldData = oldData else { return nil }
      return .init(changeset: newData.makeChangeset(from: oldData), oldData: oldData)
    }
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
      let reuseID = reuseIDStore.reuseID(for: viewDifferentiator)
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
      let reuseID = reuseIDStore.reuseID(for: viewDifferentiator)
      collectionView.register(
        supplementaryViewReuseID: reuseID,
        forKind: elementKind)
    }
  }

}

// MARK: UICollectionViewDataSource

extension CollectionViewEpoxyDataSource: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard let data = data else { return 0 }

    return data.sections.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int
  {
    guard let data = data else { return 0 }

    return data.sections[section].items.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    guard let item = data?.item(at: indexPath) else {
      // The `item(…)` method asserts in this scenario.
      return UICollectionViewCell()
    }

    let reuseID = reuseIDStore.reuseID(for: item.viewDifferentiator)
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseID,
      for: indexPath)

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
    guard let model = data?.supplementaryItem(ofKind: kind, at: indexPath) else {
      // The `supplementaryItem(…)` method asserts in this scenario.
      return UICollectionReusableView()
    }

    let reuseID = reuseIDStore.reuseID(for: model.viewDifferentiator)
    let supplementaryView = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: reuseID,
      for: indexPath)

    if let supplementaryView = supplementaryView as? CollectionViewReusableView {
      self.collectionView?.configure(
        supplementaryView: supplementaryView,
        with: model,
        animated: false)
    } else {
      EpoxyLogger.shared.assertionFailure(
        "Only CollectionViewReusableView and subclasses are allowed in a CollectionView.")
    }

    return supplementaryView
  }

  func collectionView(
    _ collectionView: UICollectionView,
    canMoveItemAt indexPath: IndexPath)
    -> Bool
  {
    guard let item = data?.item(at: indexPath) else { return false }
    return item.isMovable
  }

  func collectionView(
    _ collectionView: UICollectionView,
    moveItemAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath)
  {
    guard
      let data = data,
      let currentItem = data.item(at: sourceIndexPath)?.dataID,
      let currentSectionID = data.section(at: sourceIndexPath.section)?.dataID,
      let destinationSection = data.section(at: destinationIndexPath.section)?.dataID
    else {
      return
    }

    let beforeIndexPath = IndexPath(
      item: destinationIndexPath.item,
      section: destinationIndexPath.section)

    // We do all this extra checking just so that it doesn't crash on debug/alpha/beta
    if
      data.sections[beforeIndexPath.section].items.count >= beforeIndexPath.item + 1,
      let destinationBeforeDataID = data.item(at: beforeIndexPath)?.dataID
    {
      reorderingDelegate?.dataSource(
        self,
        moveItemWithDataID: currentItem,
        inSectionWithDataID: currentSectionID,
        toSectionWithDataID: destinationSection,
        withDestinationDataId: destinationBeforeDataID)
    }
  }

}
