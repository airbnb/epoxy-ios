// Created by eric_horacek on 3/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

/// Source code for `EpoxyCollectionView` "Tap me" example from `README.md`:
extension CollectionViewController {
  static func makeTapMeViewController() -> CollectionViewController {
    enum DataID {
      case row
    }

    return CollectionViewController(
      layout: UICollectionViewCompositionalLayout.list,
      items: {
        TextRow.itemModel(
          dataID: DataID.row,
          content: .init(title: "Tap me!"),
          style: .small)
          .didSelect { _ in
            // Handle selection
          }
      })
  }
}
