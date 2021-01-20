// Created by nick_miller on 7/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

protocol CollectionViewCellAccessibilityDelegate: AnyObject {
  func collectionViewCellDidBecomeFocused(cell: CollectionViewCell)
  func collectionViewCellDidLoseFocus(cell: CollectionViewCell)
}
