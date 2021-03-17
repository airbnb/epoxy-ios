// Created by eric_horacek on 1/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

extension CollectionViewController {
  static func readmeExamplesViewController(
    didSelect: @escaping (ReadmeExample) -> Void)
    -> CollectionViewController
  {
    CollectionViewController(layout: UICollectionViewCompositionalLayout.list, items: {
      ReadmeExample.allCases.map { example in
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
