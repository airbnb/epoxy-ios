// Created by nick_miller on 7/16/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public protocol CollectionViewAccessibilityDelegate: class {
  func collectionView(
    _ collectionView: CollectionView,
    itemDidBecomeFocused item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  func collectionView(
    _ collectionView: CollectionView,
    itemDidLoseFocus item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)
}
