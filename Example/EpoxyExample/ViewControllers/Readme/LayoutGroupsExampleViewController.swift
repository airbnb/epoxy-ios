// Created by Tyler Hedrick on 4/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

extension CollectionViewController {
  static func layoutGroupsExampleViewController(
    didSelect: @escaping (LayoutGroupsExample) -> Void)
    -> CollectionViewController
  {
    CollectionViewController(layout: UICollectionViewCompositionalLayout.list, items: {
      LayoutGroupsExample.allCases.map { example in
        TextRow.itemModel(
          dataID: example,
          content: .init(title: example.title, body: example.body),
          style: .small)
          .didSelect { _ in
            didSelect(example)
          }
      }
    })
  }
}
