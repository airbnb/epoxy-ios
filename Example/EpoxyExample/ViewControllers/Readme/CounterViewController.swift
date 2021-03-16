// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

/// Source code for `EpoxyCollectionView` "Counter" example from `README.md`:
class CounterViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    super.init(layout: UICollectionViewCompositionalLayout.list)
    setItems(items, animated: false)
  }

  // MARK: Private

  private enum DataID {
    case row
  }

  private var count = 0 {
    didSet { setItems(items, animated: true) }
  }

  @ItemModelBuilder private var items: [ItemModeling] {
    TextRow.itemModel(
      dataID: DataID.row,
      content: .init(
        title: "Count \(count)",
        body: "Tap to increment"),
      style: .large)
      .didSelect { [weak self] _ in
        self?.count += 1
      }
  }
}
