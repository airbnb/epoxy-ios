// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

/// Source code for `EpoxyCollectionView` "Counter" example from `README.md`:
class CounterViewController: CollectionViewController {
  init() {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    setSections(sections, animated: false)
  }

  private enum DataID {
    case row
  }

  private var count = 0 {
    didSet { setSections(sections, animated: true) }
  }

  private var sections: [SectionModel] {
    [
      SectionModel(items: [
        TextRow.itemModel(
          dataID: DataID.row,
          content: .init(
            title: "Count \(count)",
            body: "Tap to increment"),
          style: .large)
          .didSelect { [weak self] _ in
            self?.count += 1
          }
      ])
    ]
  }
}
