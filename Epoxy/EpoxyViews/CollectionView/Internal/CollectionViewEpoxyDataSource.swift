//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

protocol CollectionViewDataSourceReorderingDelegate: AnyObject {
  func dataSource(
    _ dataSource: CollectionViewEpoxyDataSource,
    moveItemWithDataID dataID: AnyHashable,
    inSectionWithDataID fromSectionDataID: AnyHashable,
    toSectionWithDataID toSectionDataID: AnyHashable,
    withDestinationDataId destinationDataId: AnyHashable)
}

public class CollectionViewEpoxyDataSource: EpoxyDataSource<CollectionView>,
  UICollectionViewDataSource
{

  // MARK: Public

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard let data = internalData else { return 0 }

    return data.sections.count
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int
  {
    guard let data = internalData else { return 0 }

    return data.sections[section].items.count
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    guard let item = epoxyItem(at: indexPath) else {
      epoxyLogger.epoxyAssertionFailure("Index path is out of bounds.")
      return UICollectionViewCell(frame: .zero)
    }

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: item.reuseID,
      for: indexPath)

    if let cell = cell as? CollectionViewCell {
      epoxyInterface?.configure(cell: cell, with: item)
    } else {
      epoxyLogger.epoxyAssertionFailure("Only CollectionViewCell and subclasses are allowed in a CollectionView.")
    }
    return cell
  }

  public func collectionView(
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
    guard let elementSupplementaryModel = data.sections[indexPath.section].supplementaryModels[kind]?[indexPath.item] else {
      epoxyLogger.epoxyAssertionFailure("Supplementary epoxy models not found for the given element kind and index path.")
      return UICollectionReusableView()
    }

    let supplementaryView = collectionView.dequeueReusableSupplementaryView(
      ofKind: elementSupplementaryModel.elementKind,
      withReuseIdentifier: elementSupplementaryModel.reuseID,
      for: indexPath)

    if let supplementaryView = supplementaryView as? CollectionViewReusableView {
      epoxyInterface?.configure(supplementaryView: supplementaryView, with: elementSupplementaryModel)
    } else {
      epoxyLogger.epoxyAssertionFailure("Only CollectionViewReusableView and subclasses are allowed in a CollectionView.")
    }
    return supplementaryView
  }

  public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    guard let item = epoxyItem(at: indexPath) else { return false }
    return item.isMovable
  }

  public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard let currentItem = epoxyItem(at: sourceIndexPath)?.dataID,
      let currentSectionID = epoxySection(at: sourceIndexPath.section)?.dataID,
      let destinationSection = epoxySection(at: destinationIndexPath.section)?.dataID
    else {
      return
    }

    let beforeIndexPath = IndexPath(item: destinationIndexPath.item, section: destinationIndexPath.section)

    // We do all this extra checking just so that it doesn't crash on debug/alpha/beta

    if let data = internalData,
      data.sections[beforeIndexPath.section].items.count >= beforeIndexPath.item + 1,
      let destinationBeforeDataID = epoxyItem(at: beforeIndexPath)?.dataID {
      reorderingDelegate?.dataSource(
        self,
        moveItemWithDataID: currentItem,
        inSectionWithDataID: currentSectionID,
        toSectionWithDataID: destinationSection,
        withDestinationDataId: destinationBeforeDataID)
    }
  }

  // MARK: Internal

  weak var reorderingDelegate: CollectionViewDataSourceReorderingDelegate?

  func epoxyItem(at indexPath: IndexPath) -> EpoxyModelWrapper? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < indexPath.section + 1 {
      return nil
    }

    let section = data.sections[indexPath.section]

    if section.items.count < indexPath.row + 1 {
      epoxyLogger.epoxyAssertionFailure("Item is out of bounds. Make sure your EpoxySections and EpoxyModels all have unique dataIDs")
      return nil
    }

    return section.items[indexPath.row]
  }

  func epoxyItemIfPresent(at indexPath: IndexPath) -> EpoxyModelWrapper? {
    guard let data = internalData,
      indexPath.section < data.sections.count else { return nil }

    let section = data.sections[indexPath.section]
    guard indexPath.row < section.items.count else { return nil }

    return section.items[indexPath.row]
  }

  func epoxySection(at index: Int) -> InternalEpoxySection? {
    guard let data = internalData else {
      epoxyLogger.epoxyAssertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < index + 1 {
      epoxyLogger.epoxyAssertionFailure("Section is out of bounds. Make sure your EpoxySections and EpoxyModels all have unique dataIDs")
      return nil
    }

    return data.sections[index]
  }

  func epoxySectionIfPresent(at index: Int) -> InternalEpoxySection? {
    guard let data = internalData else { return nil }
    guard index < data.sections.count else { return nil }

    return data.sections[index]
  }

  func supplementaryModelIfPresent(
    ofKind elementKind: String,
    at indexPath: IndexPath) -> SupplementaryViewEpoxyableModel?
  {
    guard let data = internalData,
      indexPath.section < data.sections.count else { return nil }

    let section = data.sections[indexPath.section]

    guard let models = section.supplementaryModels[elementKind] else { return nil }
    guard indexPath.item < models.count else { return nil }

    return models[indexPath.item]
  }
}
