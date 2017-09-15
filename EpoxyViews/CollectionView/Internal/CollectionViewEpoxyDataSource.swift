//  Created by Laura Skelton on 5/19/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

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
      assertionFailure("Index path is out of bounds.")
      return UICollectionViewCell(frame: .zero)
    }

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: item.reuseID,
      for: indexPath)

    if let cell = cell as? CollectionViewCell {
      epoxyInterface?.configure(cell: cell, with: item)
    } else {
      assertionFailure("Only CollectionViewCell and subclasses are allowed in a CollectionView.")
    }
    return cell
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath) -> UICollectionReusableView
  {
    guard let data = internalData else {
      assertionFailure("Can't load epoxy item with nil data")
      return UICollectionReusableView()
    }
    guard indexPath.section < data.sections.count else {
      assertionFailure("Index of supplementary view is out of bounds.")
      return UICollectionReusableView()
    }
    guard let elementSupplementaryModel = data.sections[indexPath.section].supplementaryModels?[kind]?[indexPath.item] else {
      assertionFailure("Supplementary epoxy models not found for the given element kind and index path.")
      return UICollectionReusableView()
    }

    let supplementaryView = collectionView.dequeueReusableSupplementaryView(
      ofKind: elementSupplementaryModel.elementKind,
      withReuseIdentifier: elementSupplementaryModel.reuseID,
      for: indexPath)

    if let supplementaryView = supplementaryView as? CollectionViewReusableView {
      epoxyInterface?.configure(supplementaryView: supplementaryView, with: elementSupplementaryModel)
    } else {
      assertionFailure("Only CollectionViewReusableView and subclasses are allowed in a CollectionView.")
    }
    return supplementaryView
  }

  // MARK: Internal

  func epoxyItem(at indexPath: IndexPath) -> CollectionView.DataType.Item? {
    guard let data = internalData else {
      assertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < indexPath.section + 1 {
      return nil
    }

    let section = data.sections[indexPath.section]

    if section.items.count < indexPath.row + 1 {
      assertionFailure("Item is out of bounds.")
      return nil
    }

    return section.items[indexPath.row]
  }

  func epoxySection(at index: Int) -> EpoxyCollectionViewSection? {
    guard let data = internalData else {
      assertionFailure("Can't load epoxy item with nil data")
      return nil
    }

    if data.sections.count < index + 1 {
      assertionFailure("Section is out of bounds.")
      return nil
    }

    return data.sections[index]
  }
}
