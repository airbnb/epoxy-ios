//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

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

  // MARK: Lifecycle

  init(epoxyLogger: EpoxyLogging, usesBatchUpdatesForAllReloads: Bool) {
    self.epoxyLogger = epoxyLogger
    self.usesBatchUpdatesForAllReloads = usesBatchUpdatesForAllReloads
    super.init()
  }

  // MARK: Internal

  let epoxyLogger: EpoxyLogging

  weak var reorderingDelegate: CollectionViewDataSourceReorderingDelegate?

  weak var collectionView: CollectionView? {
    didSet {
      reregisterReuseIDs()
    }
  }

  private(set) var internalData: InternalCollectionViewEpoxyData?

  func setSections(_ sections: [SectionModel]?, animated: Bool) {
    epoxyLogger.epoxyAssert(Thread.isMainThread, "This method must be called on the main thread.")
    registerCellReuseIDs(with: sections)
    registerSupplementaryViewReuseIDs(with: sections)
    let newInternalData: InternalCollectionViewEpoxyData?
    if let sections = sections {
      newInternalData = .make(sections: sections, epoxyLogger: epoxyLogger)
    } else {
      newInternalData = nil
    }

    applyData(newInternalData: newInternalData, animated: animated)
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
  func modifySectionsWithoutUpdating(_ sections: [SectionModel]?) {
    internalData = sections.map { .make(sections: $0, epoxyLogger: epoxyLogger) }
  }

  func item(at indexPath: IndexPath) -> AnyItemModel? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < indexPath.section + 1 {
      return nil
    }

    let section = data.sections[indexPath.section]

    if section.items.count < indexPath.row + 1 {
      epoxyLogger.epoxyAssertionFailure("Item is out of bounds. Make sure your section models and item models all have unique dataIDs")
      return nil
    }

    return section.items[indexPath.row].eraseToAnyItemModel()
  }

  func itemIfPresent(at indexPath: IndexPath) -> AnyItemModel? {
    guard let data = internalData,
      indexPath.section < data.sections.count else { return nil }

    let section = data.sections[indexPath.section]
    guard indexPath.row < section.items.count else { return nil }

    return section.items[indexPath.row].eraseToAnyItemModel()
  }

  func section(at index: Int) -> SectionModel? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < index + 1 {
      epoxyLogger.epoxyAssertionFailure("Section is out of bounds. Make sure your section models and item models all have unique dataIDs")
      return nil
    }

    return data.sections[index]
  }

  func sectionIfPresent(at index: Int) -> SectionModel? {
    guard let data = internalData else { return nil }
    guard index < data.sections.count else { return nil }

    return data.sections[index]
  }

  func supplementaryItemIfPresent(
    ofKind elementKind: String,
    at indexPath: IndexPath) -> SupplementaryViewItemModeling?
  {
    guard let data = internalData,
      indexPath.section < data.sections.count else { return nil }

    let section = data.sections[indexPath.section]

    guard let models = section.supplementaryItems[elementKind] else { return nil }
    guard indexPath.item < models.count else { return nil }

    return models[indexPath.item]
  }

  // MARK: Private

  private var cellReuseIDs = Set<String>()
  private var supplementaryViewReuseIDs = [String: Set<String>]()
  private var usesBatchUpdatesForAllReloads: Bool

  private func applyData(newInternalData: InternalCollectionViewEpoxyData?, animated: Bool) {
    collectionView?.apply(
      newInternalData,
      animated: animated,
      changesetMaker: { [unowned self] newData in
        let oldInternalData = self.internalData
        self.internalData = newData
        if self.usesBatchUpdatesForAllReloads {
          let emptyData = InternalCollectionViewEpoxyData.make(sections: [], epoxyLogger: self.epoxyLogger)
          let newData = newData ?? emptyData
          let oldData = oldInternalData ?? emptyData
          return newData.makeChangeset(from: oldData)
        } else {
          guard let oldData = oldInternalData else { return nil }
          return newData?.makeChangeset(from: oldData)
        }
      })
  }

  private func reregisterReuseIDs() {
    registerNewCellReuseIDs(cellReuseIDs)
    supplementaryViewReuseIDs.forEach { elementKind, reuseIDs in
      registerNewSupplementaryViewReuseIDs(reuseIDs, forKind: elementKind)
    }
  }

  private func registerCellReuseIDs(with sections: [SectionModel]?) {
    let newCellReuseIDs = sections?.getCellReuseIDs() ?? []
    registerNewCellReuseIDs(newCellReuseIDs.subtracting(cellReuseIDs))
    cellReuseIDs = cellReuseIDs.union(newCellReuseIDs)
  }

  private func registerSupplementaryViewReuseIDs(with sections: [SectionModel]?) {
    let newSupplementaryViewReuseIDs = sections?.getSupplementaryViewReuseIDs() ?? [:]
    newSupplementaryViewReuseIDs.forEach { elementKind, newElementSupplementaryViewReuseIDs in
      let existingReuseIDs: Set<String> = supplementaryViewReuseIDs[elementKind] ?? []
      registerNewSupplementaryViewReuseIDs(newElementSupplementaryViewReuseIDs.subtracting(existingReuseIDs), forKind: elementKind)
      supplementaryViewReuseIDs[elementKind] = existingReuseIDs.union(newElementSupplementaryViewReuseIDs)
    }
  }

  private func registerNewCellReuseIDs(_ newCellReuseIDs: Set<String>) {
    guard let collectionView = collectionView else {
      epoxyLogger.epoxyAssertionFailure("Trying to register reuse IDs before the CollectionView was set.")
      return
    }
    newCellReuseIDs.forEach { cellReuseID in
      collectionView.register(cellReuseID: cellReuseID)
    }
  }

  private func registerNewSupplementaryViewReuseIDs(_ newSupplementaryViewReuseIDs: Set<String>, forKind elementKind: String) {
    guard let collectionView = collectionView else {
      epoxyLogger.epoxyAssertionFailure("Trying to register reuse IDs before the CollectionView was set.")
      return
    }
    newSupplementaryViewReuseIDs.forEach { supplementaryViewReuseID in
      collectionView.register(supplementaryViewReuseID: supplementaryViewReuseID, forKind: elementKind)
    }
  }

}

// MARK: UICollectionViewDataSource

extension CollectionViewEpoxyDataSource: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard let data = internalData else { return 0 }

    return data.sections.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int
  {
    guard let data = internalData else { return 0 }

    return data.sections[section].items.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    guard let item = item(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds.")
      return UICollectionViewCell(frame: .zero)
    }

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: item.reuseID,
      for: indexPath)

    if let cell = cell as? CollectionViewCell {
      self.collectionView?.configure(cell: cell, with: item)
    } else {
      epoxyLogger.epoxyAssertionFailure("Only CollectionViewCell and subclasses are allowed in a CollectionView.")
    }
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath) -> UICollectionReusableView
  {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return UICollectionReusableView()
    }
    guard indexPath.section < data.sections.count else {
      epoxyLogger.epoxyAssertionFailure("Index of supplementary view is out of bounds.")
      return UICollectionReusableView()
    }
    guard let elementSupplementaryModel = data.sections[indexPath.section].supplementaryItems[kind]?[indexPath.item] else {
      epoxyLogger.epoxyAssertionFailure("Supplementary item model not found for the given element kind and index path.")
      return UICollectionReusableView()
    }

    let supplementaryView = collectionView.dequeueReusableSupplementaryView(
      ofKind: elementSupplementaryModel.elementKind,
      withReuseIdentifier: elementSupplementaryModel.reuseID,
      for: indexPath)

    if let supplementaryView = supplementaryView as? CollectionViewReusableView {
      self.collectionView?.configure(supplementaryView: supplementaryView, with: elementSupplementaryModel)
    } else {
      epoxyLogger.epoxyAssertionFailure("Only CollectionViewReusableView and subclasses are allowed in a CollectionView.")
    }
    return supplementaryView
  }

  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    guard let item = item(at: indexPath) else { return false }
    return item.isMovable
  }

  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard let currentItem = item(at: sourceIndexPath)?.dataID,
      let currentSectionID = section(at: sourceIndexPath.section)?.dataID,
      let destinationSection = section(at: destinationIndexPath.section)?.dataID
    else {
      return
    }

    let beforeIndexPath = IndexPath(item: destinationIndexPath.item, section: destinationIndexPath.section)

    // We do all this extra checking just so that it doesn't crash on debug/alpha/beta

    if let data = internalData,
      data.sections[beforeIndexPath.section].items.count >= beforeIndexPath.item + 1,
      let destinationBeforeDataID = item(at: beforeIndexPath)?.dataID {
      reorderingDelegate?.dataSource(
        self,
        moveItemWithDataID: currentItem,
        inSectionWithDataID: currentSectionID,
        toSectionWithDataID: destinationSection,
        withDestinationDataId: destinationBeforeDataID)
    }
  }

}
