// Created by eric_horacek on 11/11/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

extension UICollectionViewCompositionalLayout {
  static func example() -> UICollectionViewCompositionalLayout {
    let size = NSCollectionLayoutSize(
      widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
      heightDimension: NSCollectionLayoutDimension.estimated(150))
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }
}
