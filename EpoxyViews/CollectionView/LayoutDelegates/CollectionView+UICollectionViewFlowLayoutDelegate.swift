//  Created by Laura Skelton on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// Protocol that maps UICollectionViewDelegateFlowLayout methods to the `layoutDelegate` of a `CollectionView`
public protocol EpoxyCollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: String,
    inSectionWith sectionDataID: String) -> CGSize

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionWith sectionDataID: String) -> UIEdgeInsets

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionWith sectionDataID: String) -> CGFloat

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith sectionDataID: String) -> CGFloat
}

fileprivate let defaultItemSize = CGSize(width: 50, height: 50)
fileprivate let defaultSectionInset = UIEdgeInsets.zero
fileprivate let defaultMinimumLineSpacingForSection: CGFloat = 10
fileprivate let defaultMinimumInteritemSpacingForSection: CGFloat = 10

extension EpoxyCollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: String,
    inSectionWith sectionDataID: String) -> CGSize
  {
    return defaultItemSize
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionWith sectionDataID: String) -> UIEdgeInsets
  {
    return defaultSectionInset
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionWith sectionDataID: String) -> CGFloat
  {
    return defaultMinimumLineSpacingForSection
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith sectionDataID: String) -> CGFloat
  {
    return defaultMinimumInteritemSpacingForSection
  }
}

extension CollectionView: UICollectionViewDelegateFlowLayout {

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.itemSize
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let itemID = dataIDForItem(at: indexPath),
      let sectionID = dataIDForSection(at: indexPath.section) else {
        return defaultItemSize
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      sizeForItemWith: itemID,
      inSectionWith: sectionID)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int) -> UIEdgeInsets
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.sectionInset
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let sectionID = dataIDForSection(at: section) else {
      return defaultSectionInset
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      insetForSectionWith: sectionID)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int) -> CGFloat
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.minimumLineSpacing
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let sectionID = dataIDForSection(at: section) else {
      return defaultMinimumLineSpacingForSection
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      minimumLineSpacingForSectionWith: sectionID)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.minimumInteritemSpacing
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let sectionID = dataIDForSection(at: section) else {
      return defaultMinimumInteritemSpacingForSection
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      minimumInteritemSpacingForSectionWith: sectionID)
  }
}
