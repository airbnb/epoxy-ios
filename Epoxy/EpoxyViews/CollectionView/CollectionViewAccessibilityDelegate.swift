// Created by nick_miller on 7/16/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public protocol CollectionViewAccessibilityDelegate: class {
  func collectionView(
    _ collectionView: CollectionView,
    epoxyModelDidBecomeFocused model: EpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    epoxyModelDidLoseFocus model: EpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)
}
