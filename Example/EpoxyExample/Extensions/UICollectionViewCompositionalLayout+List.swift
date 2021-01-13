// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

extension UICollectionViewCompositionalLayout {
  static func list() -> UICollectionViewCompositionalLayout {
    if #available(iOS 14, *) {
      return UICollectionViewCompositionalLayout { _, layoutEnvironment in
        .list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
      }
    } else {
      return listNoDividers()
    }
  }

  static func listNoDividers() -> UICollectionViewCompositionalLayout {
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
