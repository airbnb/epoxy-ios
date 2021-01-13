// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

extension UICollectionViewCompositionalLayout {
  static func list() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) in
      if #available(iOS 14, *) {
        return .list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
      } else {
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))

        let group = NSCollectionLayoutGroup.vertical(
          layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)),
          subitems: [item])

        return NSCollectionLayoutSection(group: group)
      }
    }
    return layout
  }
}
