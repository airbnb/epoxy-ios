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
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemWith _: AnyHashable,
    inSectionWith _: AnyHashable)
    -> CGSize
  {
    size
  }

  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    insetForSectionWith _: AnyHashable)
    -> UIEdgeInsets
  {
    sectionInset
  }

  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    minimumLineSpacingForSectionWith _: AnyHashable)
    -> CGFloat
  {
    minimumLineSpacing
  }

  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    minimumInteritemSpacingForSectionWith _: AnyHashable)
    -> CGFloat
  {
    minimumInteritemSpacing
  }

  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    referenceSizeForHeaderInSectionWith _: AnyHashable)
    -> CGSize
  {
    headerSize
  }

  func collectionView(
    _: UICollectionView,
    layout _: UICollectionViewLayout,
    referenceSizeForFooterInSectionWith _: AnyHashable)
    -> CGSize
  {
    footerSize
  }
}
