// Created by eric_horacek on 11/11/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit
import EpoxyCollectionView

// MARK: - UICollectionViewCompositionalLayout

extension UICollectionViewCompositionalLayout {
  static func example() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(150))

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: 1)

    let section = NSCollectionLayoutSection(group: group)

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: itemSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    section.boundarySupplementaryItems = [sectionHeader]

    return UICollectionViewCompositionalLayout(section: section)
  }
}
