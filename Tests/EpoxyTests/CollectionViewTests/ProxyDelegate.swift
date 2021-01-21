// Created by Tyler Hedrick on 1/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

class ProxyDelegate: EpoxyCollectionViewDelegateFlowLayout {
  let size = CGSize(width: 12, height: 12)
  let sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
  let minimumLineSpacing: CGFloat = 12
  let minimumInteritemSpacing: CGFloat = 12
  let headerSize = CGSize(width: 12, height: 12)
  let footerSize = CGSize(width: 12, height: 12)

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemWith dataID: AnyHashable,
    inSectionWith sectionDataID: AnyHashable)
    -> CGSize
  {
    size
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionWith sectionDataID: AnyHashable)
    -> UIEdgeInsets
  {
    sectionInset
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionWith sectionDataID: AnyHashable)
    -> CGFloat
  {
    minimumLineSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith sectionDataID: AnyHashable)
    -> CGFloat
  {
    minimumInteritemSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSectionWith sectionDataID: AnyHashable)
    -> CGSize
  {
    headerSize
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSectionWith sectionDataID: AnyHashable)
    -> CGSize
  {
    footerSize
  }
}
