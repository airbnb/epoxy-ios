//  Created by Laura Skelton on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// Protocol that maps UICollectionViewDelegateFlowLayout methods to the `layoutDelegate` of a `CollectionView`
public protocol EpoxyCollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: String,
    inSectionWith sectionDataID: AnyHashable) -> CGSize

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionWith sectionDataID: AnyHashable) -> UIEdgeInsets

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionWith sectionDataID: AnyHashable) -> CGFloat

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith sectionDataID: AnyHashable) -> CGFloat

 func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSectionWith sectionDataID: AnyHashable) -> CGSize

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSectionWith sectionDataID: AnyHashable) -> CGSize
}

private let defaultItemSize = CGSize(width: 50, height: 50)
private let defaultSectionInset = UIEdgeInsets.zero
private let defaultMinimumLineSpacingForSection: CGFloat = 10
private let defaultMinimumInteritemSpacingForSection: CGFloat = 10
private let defaultHeaderReferenceSize: CGSize = .zero
private let defaultFooterReferenceSize: CGSize = .zero

extension EpoxyCollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: String,
    inSectionWith sectionDataID: AnyHashable) -> CGSize
  {
    return defaultItemSize
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionWith sectionDataID: AnyHashable) -> UIEdgeInsets
  {
    return defaultSectionInset
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionWith sectionDataID: AnyHashable) -> CGFloat
  {
    return defaultMinimumLineSpacingForSection
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith sectionDataID: AnyHashable) -> CGFloat
  {
    return defaultMinimumInteritemSpacingForSection
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSectionWith sectionDataID: AnyHashable) -> CGSize
  {
    return defaultHeaderReferenceSize
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSectionWith sectionDataID: AnyHashable) -> CGSize
  {
    return defaultFooterReferenceSize
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

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.headerReferenceSize
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let sectionID = dataIDForSection(at: section) else {
      return defaultHeaderReferenceSize
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      referenceSizeForHeaderInSectionWith: sectionID)
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSection section: Int) -> CGSize
  {
    guard let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout else {
      if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
        return flowLayout.footerReferenceSize
      } else {
        preconditionFailure("UICollectionViewDelegateFlowLayout method called with no UICollectionViewFlowLayout.")
      }
    }

    guard let sectionID = dataIDForSection(at: section) else {
      return defaultFooterReferenceSize
    }

    return flowLayoutDelegate.collectionView(
      collectionView,
      layout: collectionViewLayout,
      referenceSizeForFooterInSectionWith: sectionID)
  }
}
