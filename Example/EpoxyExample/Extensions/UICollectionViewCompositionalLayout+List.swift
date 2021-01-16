// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

// MARK: - UICollectionViewCompositionalLayout

extension UICollectionViewCompositionalLayout {
  static var list: UICollectionViewCompositionalLayout {
    if #available(iOS 14, *) {
      return UICollectionViewCompositionalLayout { _, layoutEnvironment in
        .list(layoutEnvironment: layoutEnvironment)
      }
    }
    return listNoDividers
  }

  static var listWithHeader: UICollectionViewCompositionalLayout {
    if #available(iOS 14, *) {
      return UICollectionViewCompositionalLayout { _, layoutEnvironment in
        .listWithHeader(layoutEnvironment: layoutEnvironment)
      }
    }
    return listNoDividers
  }

  static var listNoDividers: UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { sectionIndex, _ in
      let item = NSCollectionLayoutItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)),
        subitems: [item])

      return NSCollectionLayoutSection(group: group)
    }
  }
}

// MARK: - NSCollectionLayoutSection

extension NSCollectionLayoutSection {
  static var carouselWithHeader: NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(
      layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(50)))

    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(50)),
      subitems: [item])
    group.contentInsets = .zero

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    section.boundarySupplementaryItems = [sectionHeader]

    return section
  }

  static func listWithHeader(
    layoutEnvironment: NSCollectionLayoutEnvironment)
    -> NSCollectionLayoutSection
  {
    let section = list(layoutEnvironment: layoutEnvironment)

    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)

    section.boundarySupplementaryItems = [sectionHeader]

    return section
  }

  static func list(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
    if #available(iOS 14, *) {
      return .list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
    }

    let item = NSCollectionLayoutItem(
      layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))

    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)),
      subitems: [item])

    return NSCollectionLayoutSection(group: group)
  }
}
