//  Created by Laura Skelton on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - EpoxyCollectionViewDelegateFlowLayout

/// Protocol that maps `UICollectionViewDelegateFlowLayout` methods to the `layoutDelegate` of a
/// `CollectionView`.
public protocol EpoxyCollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: AnyHashable,
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

// MARK: - FlowLayoutDefaults

enum FlowLayoutDefaults {
  fileprivate static var itemSize = CGSize(width: 50, height: 50)
  fileprivate static var sectionInset = UIEdgeInsets.zero
  fileprivate static var minimumLineSpacing: CGFloat = 10
  fileprivate static var minimumInteritemSpacing: CGFloat = 10
  fileprivate static var headerReferenceSize: CGSize = .zero
  fileprivate static var footerReferenceSize: CGSize = .zero
}

extension EpoxyCollectionViewDelegateFlowLayout {
  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemWith _: AnyHashable,
    inSectionWith _: AnyHashable)
    -> CGSize
  {
    FlowLayoutDefaults.itemSize
  }

  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    insetForSectionWith _: AnyHashable)
    -> UIEdgeInsets
  {
    FlowLayoutDefaults.sectionInset
  }

  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    minimumLineSpacingForSectionWith _: AnyHashable)
    -> CGFloat
  {
    FlowLayoutDefaults.minimumLineSpacing
  }

  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith _: AnyHashable)
    -> CGFloat
  {
    FlowLayoutDefaults.minimumInteritemSpacing
  }

  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    referenceSizeForHeaderInSectionWith _: AnyHashable)
    -> CGSize
  {
    FlowLayoutDefaults.headerReferenceSize
  }

  public func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    referenceSizeForFooterInSectionWith _: AnyHashable)
    -> CGSize
  {
    FlowLayoutDefaults.footerReferenceSize
  }

}

// MARK: - CollectionView + UICollectionViewDelegateFlowLayout

extension CollectionView: UICollectionViewDelegateFlowLayout {

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath)
    -> CGSize
  {
    guard
      let item = item(at: indexPath),
      let section = section(at: indexPath.section)
    else {
      return FlowLayoutDefaults.itemSize
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        sizeForItemWith: item.dataID,
        inSectionWith: section.dataID)
    }

    // Then check the item and section at this index path
    // prioritize the item, then check the section
    if let itemSize = item.flowLayoutItemSize ?? section.flowLayoutItemSize {
      return itemSize
    }

    // Finally check the values provided to the `UICollectionViewFlowLayout`
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.itemSize
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.itemSize
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int)
    -> UIEdgeInsets
  {
    guard let section = self.section(at: section) else {
      return FlowLayoutDefaults.sectionInset
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        insetForSectionWith: section.dataID)
    }

    // Then check the section at this index path
    if let insets = section.flowLayoutSectionInset {
      return insets
    }

    // Finally, use the `UICollectionViewFlowLayout` value (or the default)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.sectionInset
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.sectionInset
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int)
    -> CGFloat
  {
    guard let section = self.section(at: section) else {
      return FlowLayoutDefaults.minimumLineSpacing
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        minimumLineSpacingForSectionWith: section.dataID)
    }

    // Then check the section at this index path
    if let lineSpacing = section.flowLayoutMinimumLineSpacing {
      return lineSpacing
    }

    // Finally, use the `UICollectionViewFlowLayout` value (or the default)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.minimumLineSpacing
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.minimumLineSpacing
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int)
    -> CGFloat
  {
    guard let section = self.section(at: section) else {
      return FlowLayoutDefaults.minimumInteritemSpacing
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        minimumInteritemSpacingForSectionWith: section.dataID)
    }

    // Then check the section at this index path
    if let interitemSpacing = section.flowLayoutMinimumInteritemSpacing {
      return interitemSpacing
    }

    // Finally, use the `UICollectionViewFlowLayout` value (or the default)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.minimumInteritemSpacing
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.minimumInteritemSpacing
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int)
    -> CGSize
  {
    guard let section = self.section(at: section) else {
      return FlowLayoutDefaults.headerReferenceSize
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        referenceSizeForHeaderInSectionWith: section.dataID)
    }

    // Then check the section at this index path
    if let headerSize = section.flowLayoutHeaderReferenceSize {
      return headerSize
    }

    // Finally, use the `UICollectionViewFlowLayout` value (or the default)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.headerReferenceSize
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.headerReferenceSize
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSection section: Int)
    -> CGSize
  {
    guard let section = self.section(at: section) else {
      return FlowLayoutDefaults.footerReferenceSize
    }

    // Check the delegate first
    if let flowLayoutDelegate = layoutDelegate as? EpoxyCollectionViewDelegateFlowLayout {
      return flowLayoutDelegate.collectionView(
        collectionView,
        layout: collectionViewLayout,
        referenceSizeForFooterInSectionWith: section.dataID)
    }

    // Then check the section at this index path
    if let footerSize = section.flowLayoutFooterReferenceSize {
      return footerSize
    }

    // Finally, use the `UICollectionViewFlowLayout` value (or the default)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.footerReferenceSize
    }
    EpoxyLogger.shared.assertionFailure("The UICollectionViewLayout must be of type UICollectionViewFlowLayout")
    return FlowLayoutDefaults.footerReferenceSize
  }
}
